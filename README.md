# Shardeum JSON-RPC Server in LD (Local Data) mode Docker

A docker setup for running the JSON-RPC server in LD (Local Data) mode with all of its dependencies

## Diagram

This docker container is meant to run all the services in the right dotted box of the diagram below.

![LD RPC Setup](https://github.com/shardeum/relayer-collector/raw/dev/ldrpc-setup.png)

## Prerequisites

### Archiver and distributor
You will need to have an archiver and distributor running somewhere. These configs will be provided by a shardeum representative or if you need to run a local devnet you can follow [these instructions](https://github.com/shardeum/shardeum?tab=readme-ov-file#installation) to run `shardus start 10` as well as boot a [distributor](https://github.com/shardeum/relayer-distributor) in MQ mode following the instructions as well.

- Docker

## Usage

1. Run the docker container with environment variables:
```bash
docker run -p 8080:8080 -it \
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
  ghcr.io/shardeum/ldrpc-docker-amd64:latest
```

2. The JSON-RPC server will be available at `http://localhost:8080`
3. You can now curl it: 
```bash
$ curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8080

{"jsonrpc":"2.0","id":1,"result":"0x1f92"}
```

## Run Configuration

The configuration is done through environment variables when running the container:
- `ARCHIVER_IP`: IP address of the archiver - should be provided by a shardeum representative
- `ARCHIVER_PUBKEY`: Public key of the archiver - should be provided by a shardeum representative
- `DISTRIBUTOR_IP`: IP address of the distributor - should be provided by a shardeum representative
- `DISTRIBUTOR_PUBKEY`: Public key of the distributor - should be provided by a shardeum representative
- `COLLECTOR_PUBKEY`: Your collector public key - should be generated using the following instructions
- `COLLECTOR_SECRETKEY`: Your collector secret key - should be generated using the following instructions
- `COLLECTOR_MODE`: Mode of the collector - should be `MQ`
- `RMQ_HOST`: Host of the RabbitMQ server - should be provided by a shardeum representative
- `RMQ_PORT`: Port of the RabbitMQ server - should be provided by a shardeum representative
- `RMQ_PROTOCOL`: Protocol of the RabbitMQ server - should be provided by a shardeum representative
- `RMQ_USER`: User of the RabbitMQ server - should be provided by a shardeum representative
- `RMQ_PASS`: Password of the RabbitMQ server - should be provided by a shardeum representative
- `RMQ_CYCLES_QUEUE_NAME`: Name of the cycles queue - should be provided by a shardeum representative
- `RMQ_RECEIPTS_QUEUE_NAME`: Name of the receipts queue - should be provided by a shardeum representative
- `RMQ_ORIGINAL_TXS_QUEUE_NAME`: Name of the original transactions queue - should be provided by a shardeum representative

### Volumes

If you want to persist the data between runs, you can mount volumes for the database directories:
```
  -v shardeum_db:/app/shardeum/db \
  -v relayer_collector_db:/app/relayer-collector/db \
```

## Keys
You will need to generate a collector public and secret key. The public key you will need to provide to the shardeum representative.
To generate collector public and secret keys, you can generate them using the following commands:

```bash
$ docker run -it ghcr.io/shardeum/ldrpc-docker-amd64:latest /bin/bash
root@b903ee67f879:/app$ cd shardeum/
root@b903ee67f879:/app/shardeum$ node scripts/generateWallet.js 
Public Key: <your-collector-pubkey>
Secret Key: <your-collector-secretkey>
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
$ docker exec -it $(docker ps --format '{{.Names}}' --filter ancestor=ghcr.io/shardeum/ldrpc-docker-amd64:latest) /bin/bash
root@b903ee67f879:/app$ pm2 list
```

## Github actions publishing
You can make builds and publish them via the github actions in this repository. It has inputs to the workflow that get passed to the build args for docker, and wether or not to publish to latest or not.

![image](https://github.com/user-attachments/assets/8038709b-d343-4f67-b51c-514f11019fda)
