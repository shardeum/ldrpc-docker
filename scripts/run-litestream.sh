echo "Restoring collector database at $COLLECTOR_DB_PATH"

litestream restore -o "$COLLECTOR_DB_PATH" gcs://ldrpc-seed-data/itn4/collector

echo "Restoring service validator database at $SERVICE_VALIDATOR_DB_PATH"

litestream restore -o "$SERVICE_VALIDATOR_DB_PATH" gcs://ldrpc-seed-data/itn4/shardeum
