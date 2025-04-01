export ARCHIVER_IP=104.197.117.164
export ARCHIVER_PORT=4000
export ARCHIVER_PUBKEY='d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1'
export DISTRIBUTOR_IP=104.197.117.164
export DISTRIBUTOR_PORT=6100
export DISTRIBUTOR_PUBKEY='d831bb7c09db45d47338af23ab50cac5d29ef8f3a2cd274dd741370aa472d6c1'
export RMQ_HOST=https://b-0a4de9ae-2edb-44a5-ad4d-10cf17c0dabf.mq.us-east-2.amazonaws.com
export RMQ_PORT=5672
export RMQ_PROTOCOL='amqps'
export COLLECTOR_MODE='MQ'
export CHAIN_ID=8083

# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-testnet-ldrpc-seed-data/testnet/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/shardeum-testnet-ldrpc-seed-data/testnet/shardeum"
fi
