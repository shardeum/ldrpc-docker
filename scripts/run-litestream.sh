# only set these if they arent set in the environment
if [ -z "$COLLECTOR_LITESTREAM_URL" ]; then
    export COLLECTOR_LITESTREAM_URL="gcs://ldrpc-seed-data/itn4/collector"
fi
if [ -z "$SERVICE_VALIDATOR_LITESTREAM_URL" ]; then
    export SERVICE_VALIDATOR_LITESTREAM_URL="gcs://ldrpc-seed-data/itn4/shardeum"
fi

# convert base64 to json
cat /home/node/dummy.json | base64 --decode > /home/node/dummy_creds.json
export GOOGLE_APPLICATION_CREDENTIALS="/home/node/dummy_creds.json"

# if we have a collector database already dont litestream restore it
if [ ! -f "$COLLECTOR_DB_PATH" ]; then
    echo "Restoring collector database at $COLLECTOR_DB_PATH"
    attempt=1
    max_attempts=3
    until litestream restore -o "$COLLECTOR_DB_PATH" "$COLLECTOR_LITESTREAM_URL" || [ $attempt -eq $max_attempts ]; do
        echo "Attempt $attempt failed. Retrying collector database restore..."
        attempt=$((attempt + 1))
        sleep 1
    done
    if [ $attempt -eq $max_attempts ] && [ ! -f "$COLLECTOR_DB_PATH" ]; then
        echo "Failed to restore collector database after $max_attempts attempts"
        exit 1
    fi
fi

# if we have a service validator database already dont litestream restore it
if [ ! -f "$SERVICE_VALIDATOR_DB_PATH" ]; then
    echo "Restoring service validator database at $SERVICE_VALIDATOR_DB_PATH"
    attempt=1
    max_attempts=3
    until litestream restore -o "$SERVICE_VALIDATOR_DB_PATH" "$SERVICE_VALIDATOR_LITESTREAM_URL" || [ $attempt -eq $max_attempts ]; do
        echo "Attempt $attempt failed. Retrying service validator database restore..."
        attempt=$((attempt + 1))
        sleep 1
    done
    if [ $attempt -eq $max_attempts ] && [ ! -f "$SERVICE_VALIDATOR_DB_PATH" ]; then
        echo "Failed to restore service validator database after $max_attempts attempts"
        exit 1
    fi
fi

