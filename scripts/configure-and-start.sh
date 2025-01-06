#!/bin/bash

# Configure Validator
cd /app/shardeum
jq ".server.p2p.existingArchivers[].ip |= \"$ARCHIVER_IP\"" config.json > tmp.json && mv tmp.json config.json
jq ".server.p2p.existingArchivers[].publicKey |= \"$ARCHIVER_PUBKEY\"" config.json > tmp.json && mv tmp.json config.json
sed -i "s/startInServiceMode: false/startInServiceMode: true/" src/shardeum/shardeumFlags.ts
npm run prepare

# Configure Relayer Collector
cd /app/relayer-collector
jq --arg ip "$DISTRIBUTOR_IP" \
   --arg dkey "$DISTRIBUTOR_PUBKEY" \
   --arg ckey "$COLLECTOR_PUBKEY" \
   --arg skey "$COLLECTOR_SECRETKEY" \
   '.distributorInfo.ip |= $ip | .distributorInfo.publicKey |= $dkey | .collectorInfo.publicKey |= $ckey | .collectorInfo.secretKey |= $skey' \
   config.json > temp.json && mv temp.json config.json

sed -i "s#enableCollectorSocketServer: false#enableCollectorSocketServer: true#" src/config/index.ts
sed -i "s#shardeumIndexerSqlitePath: 'shardeum.sqlite'#shardeumIndexerSqlitePath: '/app/shardeum/db/shardeum.sqlite'#" src/config/index.ts
npm run prepare

# Configure JSON RPC Server
cd /app/json-rpc-server
jq --arg ip "$ARCHIVER_IP" --arg key "$ARCHIVER_PUBKEY" \
   '.archivers[].ip |= $ip | .archivers[].publicKey |= $key' \
   archiverConfig.json > tmp.json && mv tmp.json archiverConfig.json

sed -i "/collectorSourcing/,/},/ s/enabled: false/enabled: true/" src/config.ts
sed -i "s|collectorApiServerUrl: 'http[^']*'|collectorApiServerUrl: 'http://0.0.0.0:6101'|g" src/config.ts
sed -i "s/serveSubscriptions: Boolean(process.env.WS_SAVE_SUBSCRIPTIONS) || false/serveSubscriptions: Boolean(process.env.WS_SAVE_SUBSCRIPTIONS) || true/" src/config.ts
npm run compile

# Start services
cd /app && pm2 start ecosystem.config.js && pm2 logs 