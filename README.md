# Shardeum JSON-RPC Server in LD (Local Data) mode Docker Compose

A docker compose setup for running the JSON-RPC server in LD (Local Data) mode with all of its dependencies

Note: this setup is still a WIP and is not ready for production use.

## Prerequisites

- Docker

## Usage

1. Clone the repository
2. Run `docker build -f Dockerfile -t shardeum-jsonrpc-ld-all-test .`

```
docker build -f Dockerfile \
  -t shardeum-jsonrpc-ld-all-test \
  --build-arg ARCHIVER_IP=<archiver-ip> \
  --build-arg ARCHIVER_PUBKEY=<archiver-pubkey> \
  --build-arg DISTRIBUTOR_PUBKEY=<distributor-pubkey> \
  --build-arg COLLECTOR_PUBKEY=<your-collector-pubkey> \
  --build-arg COLLECTOR_SECRETKEY=<your-collector-secretkey> \
```

3. Run `docker run -p 8080:8080 -it shardeum-jsonrpc-ld-all-test`
4. The JSON-RPC server will be available at `http://localhost:8080`
5. You can now curl it: 
```
$ curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8080`
{"jsonrpc":"2.0","id":1,"result":"0x1f92"}
```

## Configuration

The configuration is done in the `docker-compose.yml` file.

## Patches

The `patches/` directory contains patches for the relevant services.

