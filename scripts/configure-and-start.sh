#!/bin/bash

# Check for required environment variables
required_vars=(
  ARCHIVER_IP
  ARCHIVER_PORT
  ARCHIVER_PUBKEY
  DISTRIBUTOR_IP
  DISTRIBUTOR_PUBKEY
  COLLECTOR_PUBKEY
  COLLECTOR_SECRETKEY
  COLLECTOR_MODE
)

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
cd /home/shardeum/shardeum
jq ".server.p2p.existingArchivers[].ip |= \"$ARCHIVER_IP\"" config.json > tmp.json && mv tmp.json config.json
jq ".server.p2p.existingArchivers[].port |= \"$ARCHIVER_PORT\"" config.json > tmp.json && mv tmp.json config.json
jq ".server.p2p.existingArchivers[].publicKey |= \"$ARCHIVER_PUBKEY\"" config.json > tmp.json && mv tmp.json config.json
sed -i "s/startInServiceMode: false/startInServiceMode: true/" src/shardeum/shardeumFlags.ts
npm run prepare

# Configure Relayer Collector
cd /home/shardeum/relayer-collector
jq --arg ip "$DISTRIBUTOR_IP" \
   --arg dkey "$DISTRIBUTOR_PUBKEY" \
   --arg ckey "$COLLECTOR_PUBKEY" \
   --arg skey "$COLLECTOR_SECRETKEY" \
   --arg mode "$COLLECTOR_MODE" \
   '.distributorInfo.ip |= $ip | .distributorInfo.publicKey |= $dkey | .collectorInfo.publicKey |= $ckey | .collectorInfo.secretKey |= $skey | .dataLogWrite = ($mode != "MQ")' \
   config.json > temp.json && mv temp.json config.json

export SERVICE_VALIDATOR_DB_PATH=/home/shardeum/shardeum/db/shardeum.sqlite
mkdir -p db
export COLLECTOR_DB_PATH=/home/shardeum/relayer-collector/db/db.sqlite3
npm run prepare

# Configure JSON RPC Server
cd /home/shardeum/json-rpc-server
jq --arg ip "$ARCHIVER_IP" --arg key "$ARCHIVER_PUBKEY" \
   '.archivers[].ip |= $ip | .archivers[].publicKey |= $key' \
   archiverConfig.json > tmp.json && mv tmp.json archiverConfig.json

sed -i "/collectorSourcing/,/},/ s/enabled: false/enabled: true/" src/config.ts
sed -i "s|collectorApiServerUrl: 'http[^']*'|collectorApiServerUrl: 'http://0.0.0.0:6101'|g" src/config.ts
sed -i "s/serveSubscriptions: Boolean(process.env.WS_SAVE_SUBSCRIPTIONS) || false/serveSubscriptions: Boolean(process.env.WS_SAVE_SUBSCRIPTIONS) || true/" src/config.ts
npm run compile

cd /home/shardeum/

# Sync litestream
./run-litestream.sh

# Start services
pm2 start ecosystem.config.js && pm2 logs
