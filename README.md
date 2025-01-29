# Shardeum JSON-RPC Server in LD (Local Data) mode Docker

A docker setup for running the JSON-RPC server in LD (Local Data) mode with all of its dependencies

## Diagram

This docker container is meant to run all the services in the right dotted box of the diagram below.

![LD RPC Setup](https://github.com/shardeum/relayer-collector/raw/dev/ldrpc-setup.png)

## Prerequisites

### Archiver and distributor
You will need to have an archiver and distributor running somewhere. These configs will be provided by a shardeum representative or if you need to run a local devnet you can follow [these instructions](https://github.com/shardeum/shardeum?tab=readme-ov-file#installation) to run `shardus start 10` as well as boot a [distributor](https://github.com/shardeum/relayer-distributor) in MQ mode following the instructions as well.

## Installation

Pull the JSON-RPC server image:
```bash
docker pull ghcr.io/shardeum/ldrpc-docker
```

## Keys

You will need to generate a collector public and secret key. The public key you will need to provide to the shardeum representative.
To generate collector public and secret keys, you can generate them using the following commands:

```bash
$ docker run -it ghcr.io/shardeum/ldrpc-docker /bin/bash
root@b903ee67f879:/app$ cd shardeum/
root@b903ee67f879:/app/shardeum$ node scripts/generateWallet.js 
Public Key: <your-collector-pubkey>
Secret Key: <your-collector-secretkey>
```

## Run the service

Run the service, replacing the env variables below like `<archiver-ip>` with the values provided to you by your contact at Shardeum

```bash
docker run -p 8080:8080 -p 6101:6101 -d \
  -v shardeum_db:/home/node/shardeum/db \
  -v relayer_collector_db:/home/node/relayer-collector/db \
  -v logs:/home/node/.pm2/logs \
  -e ARCHIVER_IP=<archiver-ip> \
  -e ARCHIVER_PORT=<archiver-port> \
  -e ARCHIVER_PUBKEY=<archiver-pubkey> \
  -e DISTRIBUTOR_IP=<distributor-ip> \
  -e DISTRIBUTOR_PUBKEY=<distributor-pubkey> \
  -e COLLECTOR_PUBKEY=<your-collector-pubkey> \
  -e COLLECTOR_SECRETKEY=<your-collector-secretkey> \
  -e COLLECTOR_MODE='MQ' \
  -e RMQ_HOST=<rmq-host> \
  -e RMQ_PORT=<rmq-port> \
  -e RMQ_PROTOCOL='amqp' \
  -e RMQ_USER=<rmq-user> \
  -e RMQ_PASS=<rmq-pass> \
  -e RMQ_CYCLES_QUEUE_NAME=<rmq-cycles-queue-name> \
  -e RMQ_RECEIPTS_QUEUE_NAME=<rmq-receipts-queue-name> \
  -e RMQ_ORIGINAL_TXS_QUEUE_NAME=<rmq-original-txs-queue-name> \
  ghcr.io/shardeum/ldrpc-docker
```

## Testing the service

The JSON-RPC server will be available at `http://localhost:8080` and you can now test it with curl: 
```bash
$ curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8080

{"jsonrpc":"2.0","id":1,"result":"0x1f92"}
```

#### Demo syncing a small devnet

https://github.com/user-attachments/assets/77efc123-38c1-4965-96fc-1f1d0dec314d

## Run Configuration

The configuration is done through environment variables when running the container. These values should be provided by your shardeum representative:

- `ARCHIVER_IP`: IP address of the archiver
- `ARCHIVER_PUBKEY`: Public key of the archiver
- `DISTRIBUTOR_IP`: IP address of the distributor
- `DISTRIBUTOR_PUBKEY`: Public key of the distributor
- `COLLECTOR_PUBKEY`: Your collector public key
- `COLLECTOR_SECRETKEY`: Your collector secret key
- `COLLECTOR_MODE`: Mode of the collector - use `MQ`, WS is deprecated 
- `RMQ_HOST`: Host of the RabbitMQ server
- `RMQ_PORT`: Port of the RabbitMQ server
- `RMQ_PROTOCOL`: Protocol of the RabbitMQ server
- `RMQ_USER`: User of the RabbitMQ server
- `RMQ_PASS`: Password of the RabbitMQ server
- `RMQ_CYCLES_QUEUE_NAME`: Name of the cycles queue
- `RMQ_RECEIPTS_QUEUE_NAME`: Name of the receipts queue
- `RMQ_ORIGINAL_TXS_QUEUE_NAME`: Name of the original transactions queue

### Volumes

If you want to persist the data between runs, you can mount volumes for the database directories:
```
  -v shardeum_db:/home/node/shardeum/db \
  -v relayer_collector_db:/home/node/relayer-collector/db \
```

## Build Configuration

The branch configuration is done through build arguments when building the container:
- `SHARDEUM_BRANCH`: Branch of the shardeum repository to use
- `RELAYER_COLLECTOR_BRANCH`: Branch of the relayer-collector repository to use
- `JSON_RPC_SERVER_BRANCH`: Branch of the json-rpc-server repository to use

Examples
```bash
docker build -f Dockerfile \
  --build-arg SHARDEUM_BRANCH=itn4-1.16.3 \
  --build-arg RELAYER_COLLECTOR_BRANCH=itn4 \
  --build-arg JSON_RPC_SERVER_BRANCH=itn4 \
  -t shardeum-jsonrpc-ld-all-test .
```

## Troubleshooting

### Debugging
you can attach to the container and check list out the services and their status with `pm2`
```bash
$ docker exec -it $(docker ps --format '{{.Names}}' --filter ancestor=ghcr.io/shardeum/ldrpc-docker:itn4-1.16.3) /bin/bash
root@b903ee67f879:/app$ pm2 list
```

## Github actions publishing
You can make builds and publish them via the github actions in this repository. It has inputs to the workflow that get passed to the build args for docker, and wether or not to publish to latest or not.

![image](https://github.com/user-attachments/assets/8038709b-d343-4f67-b51c-514f11019fda)


## Google Cloud account set up for litestream

`gcloud auth application-default login`

docker run -p 8080:8080 -it \
  -v ./shardeum_db/:/home/node/shardeum/db \
  -v ./relayer_collector_db/:/home/node/relayer-collector/db \
  -v ~/.config/gcloud:/home/node/.config/gcloud \
  -e ARCHIVER_IP \
  -e ARCHIVER_PORT \
  -e ARCHIVER_PUBKEY \
  -e DISTRIBUTOR_IP \
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
    docker-ldrpc-test

