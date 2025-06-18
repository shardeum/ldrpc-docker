#!/bin/bash

# Pull in the config based on environment (if its not custom) first so the required_vars check passes
if [ "$NETWORK" != "custom" ]; then
  source ./configs/$NETWORK.sh
fi

# Check for required environment variables
required_vars=(
  ARCHIVER_IP
  ARCHIVER_PORT
  ARCHIVER_PUBKEY
  DISTRIBUTOR_IP
  DISTRIBUTOR_PORT
  DISTRIBUTOR_PUBKEY
  COLLECTOR_PUBKEY
  COLLECTOR_SECRETKEY
  COLLECTOR_MODE
  NETWORK
)
export WS_SAVE_SUBSCRIPTIONS='true'

# Set RATE_LIMIT to false if it is not set
if [ -z "$RATE_LIMIT" ]; then
  export RATE_LIMIT=false
fi

missing_vars=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -gt 0 ]; then
  echo "ERROR: Missing required environment variables:"
  printf '%s\n' "${missing_vars[@]}"
  exit 1
fi

# Configure Service validator
cd /home/node/shardeum
jq ".server.p2p.existingArchivers[].ip |= \"$ARCHIVER_IP\"" config.json > tmp.json && mv tmp.json config.json
jq ".server.p2p.existingArchivers[].port |= \"$ARCHIVER_PORT\"" config.json > tmp.json && mv tmp.json config.json
jq ".server.p2p.existingArchivers[].publicKey |= \"$ARCHIVER_PUBKEY\"" config.json > tmp.json && mv tmp.json config.json
sed -i "s/startInServiceMode: false/startInServiceMode: true/" src/shardeum/shardeumFlags.ts
npm run prepare

# Configure Relayer Collector
cd /home/node/relayer-collector
jq --arg ip "$DISTRIBUTOR_IP" \
   --arg port "$DISTRIBUTOR_PORT" \
   --arg dkey "$DISTRIBUTOR_PUBKEY" \
   --arg ckey "$COLLECTOR_PUBKEY" \
   --arg skey "$COLLECTOR_SECRETKEY" \
   --arg mode "$COLLECTOR_MODE" \
   --arg saveReceiptsWithSignaturePacks "${SAVE_RECEIPTS_WITH_SIGNATURE_PACKS:-true}" \
   '.distributorInfo.ip |= $ip | .distributorInfo.port |= $port | .distributorInfo.publicKey |= $dkey | .collectorInfo.publicKey |= $ckey | .collectorInfo.secretKey |= $skey | .dataLogWrite = ($mode != "MQ") | .saveReceiptsWithSignaturePacks = ($saveReceiptsWithSignaturePacks == "true")' \
   config.json > temp.json && mv temp.json config.json

export SERVICE_VALIDATOR_DB_PATH=/home/node/shardeum/db/shardeum.sqlite
export COLLECTOR_DB_PATH=/home/node/relayer-collector/db/db.sqlite3

if [ -n "$SAVE_RECEIPTS_WITH_SIGNATURE_PACKS" ]; then
  export SAVE_RECEIPTS_WITH_SIGNATURE_PACKS
fi
npm run prepare

# Configure JSON RPC Server
cd /home/node/json-rpc-server
jq --arg ip "$ARCHIVER_IP" --arg key "$ARCHIVER_PUBKEY" \
   '.archivers[].ip |= $ip | .archivers[].publicKey |= $key' \
   archiverConfig.json > tmp.json && mv tmp.json archiverConfig.json

sed -i "/collectorSourcing/,/},/ s/enabled: false/enabled: true/" src/config.ts
sed -i "/serviceValidatorSourcing/,/},/ s/enabled: false/enabled: true/" src/config.ts
sed -i "s|collectorApiServerUrl: 'http[^']*'|collectorApiServerUrl: 'http://0.0.0.0:6101'|g" src/config.ts
npm run compile

cd /home/node/

# Skip backup if SKIP_BACKUP is set to 'true'
if [ "$SKIP_BACKUP_DOWNLOAD" = "true" ]; then
  echo "Skipping backup download as SKIP_BACKUP_DOWNLOAD=true"
else
  # Sync backup and dont start if it exits with an error
  if ! ./run-backup.sh; then
    echo "Failed to sync backup. Exiting early."
    exit 1
  fi
fi

# Start services
pm2 start ecosystem.config.js && pm2 logs
