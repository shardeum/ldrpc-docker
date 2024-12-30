# Shardeum JSON-RPC Server in LD (Local Data) mode Docker Compose

A docker compose setup for running the JSON-RPC server in LD (Local Data) mode with all of its dependencies

## Prerequisites

- Docker

## Usage

1. Clone the repository
2. Run `docker compose up -d`
3. Wait for the containers to start
4. The JSON-RPC server will be available at `http://localhost:8080`

## Configuration

The configuration is done in the `docker-compose.yml` file.

## Patches

The `patches/` directory contains patches for the relevant services.

