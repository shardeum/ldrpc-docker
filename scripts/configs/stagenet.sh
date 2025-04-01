export ARCHIVER_IP=34.57.177.170
export ARCHIVER_PORT=4000
export ARCHIVER_PUBKEY='d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1'
export DISTRIBUTOR_IP=34.57.177.170
export DISTRIBUTOR_PORT=6100
export DISTRIBUTOR_PUBKEY='d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1'
export RMQ_HOST=https://b-6bd7f420-1af4-4d3b-8c42-4e190249f25e.mq.us-east-2.amazonaws.com
export RMQ_PORT=5672
export RMQ_PROTOCOL='amqps'
export COLLECTOR_MODE='MQ'
export CHAIN_ID=8082

# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-stagenet-ldrpc-seed-data/stagenet/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-stagenet-ldrpc-seed-data/stagenet/shardeum"
fi