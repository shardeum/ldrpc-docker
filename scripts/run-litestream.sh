
# convert base64 to json
cat /home/node/dummy.json | base64 --decode > /home/node/dummy_creds.json
export GOOGLE_APPLICATION_CREDENTIALS="/home/node/dummy_creds.json"

# if we have a collector database already dont litestream restore it
if [ ! -f "$COLLECTOR_DB_PATH" ]; then
    echo "Restoring collector database at $COLLECTOR_DB_PATH"
    litestream restore -o "$COLLECTOR_DB_PATH" gcs://ldrpc-seed-data/itn4/collector
fi

# if we have a service validator database already dont litestream restore it
if [ ! -f "$SERVICE_VALIDATOR_DB_PATH" ]; then
    echo "Restoring service validator database at $SERVICE_VALIDATOR_DB_PATH"
    litestream restore -o "$SERVICE_VALIDATOR_DB_PATH" gcs://ldrpc-seed-data/itn4/shardeum
fi