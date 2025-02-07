export ARCHIVER_PUBKEY=2db7c949632d26b87d7e7a5a4ad41c306f63ee972655121a37c5e4f52b00a542
export ARCHIVER_IP=35.227.45.34
export ARCHIVER_PORT=4000
export DISTRIBUTOR_IP=35.227.45.34
export DISTRIBUTOR_PORT=6100
export DISTRIBUTOR_PUBKEY=2db7c949632d26b87d7e7a5a4ad41c306f63ee972655121a37c5e4f52b00a542
export COLLECTOR_PUBKEY=4a06ee7c8b9ee55669f3e51f8e20aad6821925b4a8ae497ac3b82a1a065b5d69
export COLLECTOR_SECRETKEY=9494a5a6be5e1f855f5efbe60d9cb8014f7cb2a5d93d5fd430784cf070298e774a06ee7c8b9ee55669f3e51f8e20aad6821925b4a8ae497ac3b82a1a065b5d69
export COLLECTOR_MODE='MQ'
export RMQ_HOST='3.144.111.71'
export RMQ_PORT='5672'
export RMQ_PROTOCOL='amqp'
export RMQ_USER=devnet-us.shane-collector1
export RMQ_PASS=Y4K3Bxv20TnncWyl
export RMQ_CYCLES_QUEUE_NAME=devnet-us.shane-collector1.cycles
export RMQ_RECEIPTS_QUEUE_NAME=devnet-us.shane-collector1.receipts
export RMQ_ORIGINAL_TXS_QUEUE_NAME=devnet-us.shane-collector1.originalTxs
export COLLECTOR_BACKUP_BASE_URL=https://storage.googleapis.com/ldrpc-seed-data-devnet/devnet-us/collector.devnet-us
export SERVICE_VALIDATOR_BACKUP_BASE_URL=https://storage.googleapis.com/ldrpc-seed-data-devnet/devnet-us/shardeum.devnet-us

docker run -p 8080:8080 -it \
  -v logs:/home/node/.pm2 \
  -v shardeum_db:/home/node/shardeum/db \
  -v relayer_collector_db:/home/node/relayer-collector/db \
  -e ARCHIVER_IP \
  -e ARCHIVER_PORT \
  -e ARCHIVER_PUBKEY \
  -e DISTRIBUTOR_IP \
  -e DISTRIBUTOR_PORT \
  -e DISTRIBUTOR_PUBKEY \
  -e COLLECTOR_PUBKEY \
  -e COLLECTOR_SECRETKEY \
  -e COLLECTOR_MODE \
  -e RMQ_HOST \
  -e RMQ_PORT \
  -e RMQ_PROTOCOL \
  -e RMQ_USER \
  -e RMQ_PASS \
  -e RMQ_CYCLES_QUEUE_NAME \
  -e RMQ_RECEIPTS_QUEUE_NAME \
  -e RMQ_ORIGINAL_TXS_QUEUE_NAME \
  -e COLLECTOR_BACKUP_BASE_URL \
  -e SERVICE_VALIDATOR_BACKUP_BASE_URL \
  --name=shane-test \
   docker-ldrpc-test
