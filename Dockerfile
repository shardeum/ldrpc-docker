FROM node:18.19.1-slim

# Define build arguments for repository branches
ARG SHARDEUM_BRANCH=dev
ARG RELAYER_COLLECTOR_BRANCH=dev
ARG JSON_RPC_SERVER_BRANCH=dev

# Set environment variables from build args
ENV SHARDEUM_BRANCH=${SHARDEUM_BRANCH}
ENV RELAYER_COLLECTOR_BRANCH=${RELAYER_COLLECTOR_BRANCH}
ENV JSON_RPC_SERVER_BRANCH=${JSON_RPC_SERVER_BRANCH}

ENV DEBIAN_FRONTEND=noninteractive

# Create non-root user and set up directories
RUN groupadd -r shardeum && useradd -r -g shardeum -m shardeum && \
    mkdir -p /home/shardeum/.npm-global && \
    chown -R shardeum:shardeum /home/shardeum

# Set npm to use user-specific global directory
ENV NPM_CONFIG_PREFIX=/home/shardeum/.npm-global

# Install system dependencies
RUN apt-get update && apt-get install -y jq \
    build-essential \
    curl \
    git \
    python3

# Switch to non-root user for npm global install
USER shardeum
WORKDIR /home/shardeum

ENV PATH="/home/shardeum/.npm-global/bin:/home/shardeum/.cargo/bin:${PATH}"

# Install global npm packages
RUN npm install -g pm2

# Copy and run install script
COPY scripts/install.sh .
RUN ./install.sh

# Clone and install repositories as non-root user with shallow clones
RUN git clone --depth 1 -b ${SHARDEUM_BRANCH} https://github.com/shardeum/shardeum
RUN cd shardeum && npm ci
RUN git clone --depth 1 -b ${RELAYER_COLLECTOR_BRANCH} https://github.com/shardeum/relayer-collector/
RUN cd relayer-collector && npm install
RUN git clone --depth 1 -b ${JSON_RPC_SERVER_BRANCH} https://github.com/shardeum/json-rpc-server
RUN cd json-rpc-server && npm install

# Create required directories with proper ownership
RUN mkdir -p shardeum/db && \
    chmod 750 shardeum/db

# Copy ecosystem config
COPY ecosystem.config.js /home/shardeum/

# Expose ports
EXPOSE 8080 9001 10001 4000 6100 4446 6101

# Configure services at runtime using environment variables
COPY scripts/configure-and-start.sh /home/shardeum/
COPY scripts/run-litestream.sh /home/shardeum/

CMD ["/home/shardeum/configure-and-start.sh"]