export ARCHIVER_PORT=4000
export DISTRIBUTOR_PORT=10001
export COLLECTOR_MODE='MQ'
export RMQ_HOST=0.0.0.0
export RMQ_PORT=5672
export RMQ_PROTOCOL='amqps'
export CHAIN_ID=8118

# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-mainnet-ldrpc-seed-data/mainnet/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-mainnet-ldrpc-seed-data/mainnet/shardeum"
fi


