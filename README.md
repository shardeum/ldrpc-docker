# Shardeum JSON-RPC Server in LD (Local Data) mode Docker

A docker setup for running the JSON-RPC server in LD (Local Data) mode with all of its dependencies

## Diagram

This docker container is meant to run all the services in the right dotted box of the diagram below.

![LD RPC Setup](https://github.com/shardeum/relayer-collector/raw/dev/ldrpc-setup.png)

## Prerequisites

### Archiver and distributor
You will need to have an archiver and distributor running somewhere. These configs will be provided by a shardeum representative or if you need to run a local devnet you can follow [these instructions](https://github.com/shardeum/shardeum?tab=readme-ov-file#installation) to run `shardus start 10` as well as boot a [distributor](https://github.com/shardeum/relayer-distributor) following the instructions as well.

- Docker

## Usage

1. Clone the repository
2. Build the image:
```bash
docker build -f Dockerfile -t shardeum-jsonrpc-ld-all-test .
```

3. Run the container with environment variables:
```bash
docker run -p 8080:8080 -it \
  -e ARCHIVER_IP=<archiver-ip> \
  -e ARCHIVER_PORT=<archiver-port> \
  -e ARCHIVER_PUBKEY=<archiver-pubkey> \
  -e DISTRIBUTOR_IP=<distributor-ip> \
  -e DISTRIBUTOR_PUBKEY=<distributor-pubkey> \
  -e COLLECTOR_PUBKEY=<your-collector-pubkey> \
  -e COLLECTOR_SECRETKEY=<your-collector-secretkey> \
  shardeum-jsonrpc-ld-all-test
```

4. The JSON-RPC server will be available at `http://localhost:8080`
5. You can now curl it: 
```bash
$ curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8080

{"jsonrpc":"2.0","id":1,"result":"0x1f92"}
```

## Build Configuration

The configuration is done through build arguments when building the container:
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

## Run Configuration

The configuration is done through environment variables when running the container:
- `ARCHIVER_IP`: IP address of the archiver - should be provided by a shardeum representative
- `ARCHIVER_PUBKEY`: Public key of the archiver - should be provided by a shardeum representative
- `DISTRIBUTOR_IP`: IP address of the distributor - should be provided by a shardeum representative
- `DISTRIBUTOR_PUBKEY`: Public key of the distributor - should be provided by a shardeum representative
- `COLLECTOR_PUBKEY`: Your collector public key - should be generated using the following instructions
- `COLLECTOR_SECRETKEY`: Your collector secret key - should be generated using the following instructions

## Keys
You will need to generate a collector public and secret key. The public key you will need to provide to the shardeum representative.
To generate collector public and secret keys, you can generate them using the following commands:

```bash
$ docker run -it shardeum-jsonrpc-ld-all-test /bin/bash
root@b903ee67f879:/app$ cd shardeum/
root@b903ee67f879:/app/shardeum$ node scripts/generateWallet.js 
Public Key: <your-collector-pubkey>
Secret Key: <your-collector-secretkey>
```

## Debugging
you can attach to the container and check list out the services and their status with `pm2`
```bash
$ docker exec -it $(docker ps --format '{{.Names}}' --filter ancestor=shardeum-jsonrpc-ld-all-test) /bin/bash
root@b903ee67f879:/app$ pm2 list
```
