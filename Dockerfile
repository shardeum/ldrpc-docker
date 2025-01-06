FROM node:18.16.1

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:${PATH}"

# Install jq
RUN apt-get update && apt-get install -y jq

# Install PM2 globally
RUN npm install -g pm2

# Accept build-time arguments
ARG ARCHIVER_IP
ARG ARCHIVER_PUBKEY
ARG DISTRIBUTOR_PUBKEY
ARG COLLECTOR_PUBKEY
ARG COLLECTOR_SECRETKEY

# Set environment variables from build arguments
ENV ARCHIVER_IP=${ARCHIVER_IP}
ENV ARCHIVER_PUBKEY=${ARCHIVER_PUBKEY}
ENV DISTRIBUTOR_PUBKEY=${DISTRIBUTOR_PUBKEY}
ENV COLLECTOR_PUBKEY=${COLLECTOR_PUBKEY}
ENV COLLECTOR_SECRETKEY=${COLLECTOR_SECRETKEY}

# Copy and run install script
COPY scripts/install.sh .
RUN chmod +x install.sh && ./install.sh

WORKDIR /app

# Validator
RUN git clone -b dev https://github.com/shardeum/shardeum 
RUN cd shardeum && npm ci
RUN git clone -b dev https://github.com/shardeum/relayer-collector/
RUN cd relayer-collector && npm install
RUN git clone -b dev https://github.com/shardeum/json-rpc-server
RUN cd json-rpc-server && npm install

## Validator service mode Configs
RUN cd shardeum && jq ".server.p2p.existingArchivers[].ip |= \"$ARCHIVER_IP\"" config.json > tmp.json && mv tmp.json config.json
RUN cd shardeum && jq ".server.p2p.existingArchivers[].publicKey |= \"$ARCHIVER_PUBKEY\"" config.json > tmp.json && mv tmp.json config.json
RUN cd shardeum && sed -i "s/startInServiceMode: false/startInServiceMode: true/" src/shardeum/shardeumFlags.ts
RUN cd shardeum && npm run prepare

# Relayer Collector configs
RUN cd relayer-collector && jq --arg ip "$ARCHIVER_IP" --arg dkey "$DISTRIBUTOR_PUBKEY" --arg ckey "$COLLECTOR_PUBKEY" --arg skey "$COLLECTOR_SECRETKEY" \
       '.distributorInfo.ip |= $ip | .distributorInfo.publicKey |= $dkey | .collectorInfo.publicKey |= $ckey | .collectorInfo.secretKey |= $skey' config.json > temp.json && mv temp.json config.json \
    && sed -i "s#enableCollectorSocketServer: false#enableCollectorSocketServer: true#" src/config/index.ts \
    && sed -i "s#shardeumIndexerSqlitePath: 'shardeum.sqlite'#shardeumIndexerSqlitePath: '/app/shardeum/db/shardeum.sqlite'#" src/config/index.ts \
    && npm run prepare

# JSON RPC Server configs
RUN cd json-rpc-server && jq --arg ip "$ARCHIVER_IP" --arg key "$ARCHIVER_PUBKEY" '.archivers[].ip |= $ip | .archivers[].publicKey |= $key' archiverConfig.json > tmp.json && mv tmp.json archiverConfig.json \
    && sed -i "/collectorSourcing/,/},/ s/enabled: false/enabled: true/" src/config.ts \
    && sed -i "s|collectorApiServerUrl: 'http[^']*'|collectorApiServerUrl: 'http://0.0.0.0:6101'|g" src/config.ts \
    && sed -i "s/serveSubscriptions: Boolean(process.env.WS_SAVE_SUBSCRIPTIONS) || false/serveSubscriptions: Boolean(process.env.WS_SAVE_SUBSCRIPTIONS) || true/" src/config.ts \
    # && sed -i "s#staticGasEstimate: '0x5B8D80'#//staticGasEstimate: '0x5B8D80'#" src/config.ts \
    && npm run compile

# Create required directories and database file
RUN mkdir -p /app/server/db /app/shardeum/db && \
    chmod -R 777 /app/server/db /app/shardeum/db && \
    touch /app/shardeum/db/shardeum.sqlite && \
    chmod 666 /app/shardeum/db/shardeum.sqlite

# Copy ecosystem config
COPY ecosystem.config.js /app/

# Set environment variables for services
ENV ARCHIVER_IP=${ARCHIVER_IP}
ENV DISTRIBUTOR_IP=${ARCHIVER_IP}
ENV COLLECTOR_IP=${ARCHIVER_IP}

# Expose ports
EXPOSE 8080 9001 10001 4000 6100 4446 6101

# Start services
CMD ["sh", "-c", "cd /app && pm2 start ecosystem.config.js && pm2 logs"] 