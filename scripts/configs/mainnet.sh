export ARCHIVER_PORT=4000
export DISTRIBUTOR_PORT=6100
export RMQ_PORT=5671
export RMQ_PROTOCOL='amqps'
export COLLECTOR_MODE='MQ'
export CHAIN_ID=8118

# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-mainnet-ldrpc-seed-data/mainnet/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-mainnet-ldrpc-seed-data/mainnet/shardeum"
fi


