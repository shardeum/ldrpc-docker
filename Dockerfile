FROM node:18.16.1

# Define build arguments for repository branches
ARG SHARDEUM_BRANCH=dev
ARG RELAYER_COLLECTOR_BRANCH=dev
ARG JSON_RPC_SERVER_BRANCH=dev

# Set environment variables from build args
ENV SHARDEUM_BRANCH=${SHARDEUM_BRANCH}
ENV RELAYER_COLLECTOR_BRANCH=${RELAYER_COLLECTOR_BRANCH}
ENV JSON_RPC_SERVER_BRANCH=${JSON_RPC_SERVER_BRANCH}

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:${PATH}"

# Install jq
RUN apt-get update && apt-get install -y jq

# Install PM2 globally
RUN npm install -g pm2

# Copy and run install script
COPY scripts/install.sh .
RUN chmod +x install.sh && ./install.sh

WORKDIR /app

# Validator
RUN git clone -b ${SHARDEUM_BRANCH} https://github.com/shardeum/shardeum 
RUN cd shardeum && npm ci
RUN git clone -b ${RELAYER_COLLECTOR_BRANCH} https://github.com/shardeum/relayer-collector/
RUN cd relayer-collector && npm install
RUN git clone -b ${JSON_RPC_SERVER_BRANCH} https://github.com/shardeum/json-rpc-server
RUN cd json-rpc-server && npm install

# Create required directories and database file with proper permissions
RUN mkdir -p /app/shardeum/db && \
    chmod -R 755 /app/shardeum/db

# Copy ecosystem config
COPY ecosystem.config.js /app/

# Expose ports
EXPOSE 8080 9001 10001 4000 6100 4446 6101

# Configure services at runtime using environment variables
COPY scripts/configure-and-start.sh /app/
RUN chmod +x /app/configure-and-start.sh

CMD ["/app/configure-and-start.sh"] 