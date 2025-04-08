export ARCHIVER_PORT=4000
export DISTRIBUTOR_PORT=6100
export RMQ_HOST=http://b-6bd7f420-1af4-4d3b-8c42-4e190249f25e.mq.us-east-2.amazonaws.com
export RMQ_PORT=5671
export RMQ_PROTOCOL='amqps'
export COLLECTOR_MODE='MQ'
export CHAIN_ID=8081

# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-stagenet-ldrpc-seed-data/stagenet/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-stagenet-ldrpc-seed-data/stagenet/shardeum"
fi