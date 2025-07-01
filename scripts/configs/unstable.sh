export ARCHIVER_PORT=4000
export DISTRIBUTOR_PORT=6100
export RMQ_HOST=b-8b5a5382-23d6-4a8f-b725-b7e54db6772e.mq.us-east-2.on.aws
export RMQ_PORT=5671
export RMQ_PROTOCOL='amqps'
export COLLECTOR_MODE='MQ'
export CHAIN_ID=8080

# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-unstable-ldrpc-seed-data/unstable/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-unstable-ldrpc-seed-data/unstable/shardeum"
fi
