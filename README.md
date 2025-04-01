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
node@b903ee67f879:~$ cd shardeum/
node@b903ee67f879:~/shardeum$ node scripts/generateWallet.js 
Public Key: <your-collector-pubkey>
Secret Key: <your-collector-secretkey>
```

## Run the service

Run the service, replacing the env variables below like `<archiver-ip>` with the values provided to you by your contact at Shardeum

`NETWORK` can be `mainnet` `stagenet` or `testnet`, you can also put `custom` and fill in the missing envs yourself.
```bash
docker run -p 8080:8080 -p 9001:9001 -p 10001:10001 -p 4000:4000 -p 6100:6100 -p 4446:4446 -p 4444:4444 -p 6101:6101 -d \
  -v shardeum_db:/home/node/shardeum/db \
  -v relayer_collector_db:/home/node/relayer-collector/db \
  -v logs:/home/node/.pm2 \
  -e COLLECTOR_PUBKEY=<your-collector-pubkey> \
  -e COLLECTOR_SECRETKEY=<your-collector-secretkey> \
  -e RMQ_PASS=<rmq-pass> \
  -e RMQ_CYCLES_QUEUE_NAME=<rmq-cycles-queue-name> \
  -e RMQ_RECEIPTS_QUEUE_NAME=<rmq-receipts-queue-name> \
  -e RMQ_ORIGINAL_TXS_QUEUE_NAME=<rmq-original-txs-queue-name> \
  -e NETWORK=testnet
  ghcr.io/shardeum/ldrpc-docker
```

### Custom Network
You can run a custom network configuration by passing `custom` to `-e NETWORK`, which doesnt include a predefined configuration for a network. you will need to put the missing env vars in yourself here is an example:

```bash
docker run -p 8080:8080 -p 9001:9001 -p 10001:10001 -p 4000:4000 -p 6100:6100 -p 4446:4446 -p 4444:4444 -p 6101:6101 -d \
  -v shardeum_db:/home/node/shardeum/db \
  -v relayer_collector_db:/home/node/relayer-collector/db \
  -v logs:/home/node/.pm2 \
  -e ARCHIVER_IP=<archiver-ip> \
  -e ARCHIVER_PORT=<archiver-port> \
  -e ARCHIVER_PUBKEY=<archiver-pubkey> \
  -e DISTRIBUTOR_IP=<distributor-ip> \
  -e DISTRIBUTOR_PORT=<distributor-port> \
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
  -e CHAIN_ID=<chain-id> \
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
- `DISTRIBUTOR_PORT`: PORT address of the distributor
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
- `CHAIN_ID`: The chain ID of the network

### Skip Backup Download Option

If you want to skip the backup download process during startup (not recommended for production), you can add the following environment variable:

```bash
  -e SKIP_BACKUP_DOWNLOAD=true
```

This will prevent the service from downloading a backup of the databases before starting. This can be useful during development or testing, but should not be used in production environments where data integrity is critical.

### Volumes

If you want to persist the data between runs, you can mount volumes for the database directories:

```bash
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

## Healthcheck API

### JSON-RPC Server healthcheck API

URL: <http://localhost:8080/is-healthy>

#### Sample Response

**Healthy:**

<details>
<summary>Response</summary>

```bash
{
    "status": "healthy",
    "uptime": 242434.358461458,
    "timestamp": "2025-02-10T04:54:28.110Z",
    "database": "healthy",
    "isServiceValidatorMode": false
}
```

</details>

**Unhealthy:**

<details>
<summary>Response</summary>
  
```bash
{
  "status": "degraded",
  "uptime": 12.548521417,
  "timestamp": "2025-02-03T19:58:49.088Z",
  "database": "unreachable",
  "isServiceValidatorMode": false
}
```

</details>

**Logging**

To enter the Docker container use the command

```bash
docker exec -it shardeum-collector bash
```

Logs are stored at:

- Info logs: `~/xyz/pm2/logs/json-rpc-server-out.log`
- Error logs: `~/xyz/pm2/logs/json-rpc-server-error.log`

**Important Note:** In the `json-rpc-server-out.log` file, if you see messages like `Updating NodeList from XXXX and nodelist_update: YYYms` or `<N> Healthy Archivers active in the Network` -> This means your JSON-RPC server is active and updating important network information from the network regularly.

### Collector Server healthcheck API

URL: <http://localhost:4444/is-healthy>

#### Sample Response

**Healthy:**

<details>
<summary>Response</summary>

```bash
{
  "status": "healthy",
  "uptime": 47.600131667,
  "timestamp": "2025-02-03T21:00:35.026Z",
  "database": true,
  "shardeumIndexerDb": true,
  "Cycles": "healthy",
  "OriginalTxs": "healthy",
  "Receipts": "healthy"
}
```
</details>

**Unhealthy:**

<details>
<summary>Response</summary>

```bash
{
  "status": "degraded",
  "uptime": 12.800243708,
  "timestamp": "2025-02-03T20:08:55.049Z",
  "database": true,
  "shardeumIndexerDb": true,
  "Cycles": "stuck",
  "OriginalTxs": "stuck",
  "Receipts": "stuck"
}
```
</details>

**LOGGING**

Logs are stored at:
- Info logs: ~/xyz/pm2/logs/collector-server-out.log
- Error logs: ~/xyz/pm2/logs/collector-server-error.log
  
**Important Note:** In the `collector-server-out.log` file, if you see messages like:

- `🟢 Verification successful. Updating checkpoint to XXXX` -> This means that the collector is syncing data and also verifying it successfully. Once the XXXX matches latest_cycle_from_explorer - 21 (21 is a threshold from latest cycle to trigger verification of a cycle), it means data verification is caught up with the network.

- [If verbose logging is enabled] `Downloading receipts/originalTxsData/cycles from <X> to <Y>` -> This indicates the API is syncing transaction data. These logs appear mostly during initial sync and become less frequent once syncing stabilizes.

### Collector API Server healthcheck API

URL: <http://localhost:6101/is-healthy>

#### Sample Response

**Healthy:**

<details>
<summary>Response</summary>

```bash
{
  "status": "healthy",
  "uptime": 339887.239225893,
  "timestamp": "2025-02-11T07:58:35.766Z",
  "database": true,
  "shardeumIndexerDb": true
}
```
</details>

**Unhealthy:**

<details>
<summary>Response</summary>

```bash
{
  "status": "degraded",
  "uptime": 339887.239225893,
  "timestamp": "2025-02-11T07:58:35.766Z",
  "database": false,
  "shardeumIndexerDb": true
}
```
</details>

**Checking Sync status:** During the initial sync, use the `/totalData` API to check if the collector is in sync with the network. If `totalCycles`, `totalTransactions`, and `totalOriginalTxs` approximately match what is shown on the explorer, the collector is in sync. Sync speeds vary based on RAM, disk type, and network speed.

Sample Response for `/totalData` API:

<details>
<summary>Response</summary>

```bash
{
  "accountsEntry": 9830905,
  "totalAccounts": 9830905,
  "totalCycles": 63584,
  "totalOriginalTxs": 21060677,
  "totalReceipts": 20882618,
  "totalTransactions": 20882618
}
```

**Important Note:** The `/totalData` API is resource-intensive and may respond slowly. Avoid frequent requests within a short period to prevent overloading the Collector API Server.

### Service Validator healthcheck API

URL: <http://localhost:9001/is-healthy>

#### Sample Response

**Healthy:**

<details>
<summary>Response</summary>

```bash
{
  "database": "healthy",
  "status": "healthy",
  "timestamp": "2025-02-17T15:17:18.962Z",
  "uptime": 10246.913707835
}
```
</details>

**Unhealthy:**

<details>
<summary>Response</summary>

```bash
{
    "database": "unreachable",
    "status": "degraded",
    "timestamp": "2025-02-03T19:14:30.488Z",
    "uptime": 315.109965833
}
```
</details>

## Troubleshooting

### Debugging

you can attach to the container and check list out the services and their status with `pm2`

```bash
$ docker exec -it $(docker ps --format '{{.Names}}' --filter ancestor=ghcr.io/shardeum/ldrpc-docker:itn4-1.16.3) /bin/bash
node@b903ee67f879:~$ pm2 list
```

### Handling Connection Loss

In rare cases, the Collector Server may lose its connection with RabbitMQ and fail to recover automatically. If this happens, you will see errors in the `collector-server-error.log` file, such as:
`IllegalOperationError: Channel closed` or `Connection error: Error: Channel closed by server: 406 (PRECONDITION-FAILED)`

To resolve this issue, restart the Collector Server using the following command:

```bash
docker exec -it <container-id> pm2 restart collector-server
```

### Error messages and Recovery

You may also encounter the following error messages in the logs:

- `The last stored cycle counter does not match with the last stored cycle count! Patch the missing cycle data and start the server again!`
- `The last saved receipts of last N cycles data do not match with the distributor data! Clear the DB and start the server again!`
- `The last saved originalTxsData of last N cycles data do not match with the distributor data! Clear the DB and start the server again!`
- `❗ Verification failed for cycle XXXX. Mismatching Receipts[or Transactions]`
- `Cycle XXXX is missing from the database`
- `Identified missing data for cycle: XXXX`

Please don't worry if you encounter any of the above error messages. Our systems are designed to automatically recover, sync, and verify any missing data.

## Github actions publishing
You can make builds and publish them via the github actions in this repository. It has inputs to the workflow that get passed to the build args for docker, and wether or not to publish to latest or not.

![image](https://github.com/user-attachments/assets/8038709b-d343-4f67-b51c-514f11019fda)
