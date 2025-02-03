# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_URL" ]; then
    export COLLECTOR_BACKUP_URL="https://storage.googleapis.com/ldrpc-seed-data/itn4/collector.20250131.tgz"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_URL="https://storage.googleapis.com/ldrpc-seed-data/itn4/shardeum.20250131.tgz"
fi

# if we have a collector database already dont restore it
if [ ! -f "$COLLECTOR_DB_PATH" ]; then
    echo "Restoring collector database at $COLLECTOR_DB_PATH"
    if ! curl -sL "$COLLECTOR_BACKUP_URL" | tar -xz -O > "$COLLECTOR_DB_PATH"; then
        echo "Failed to restore collector database"
        exit 1
    fi
fi

# if we have a service validator database already dont restore it
if [ ! -f "$SERVICE_VALIDATOR_DB_PATH" ]; then
    echo "Restoring service validator database at $SERVICE_VALIDATOR_DB_PATH"
    if ! curl -sL "$SERVICE_VALIDATOR_BACKUP_URL" | tar -xz -O > "$SERVICE_VALIDATOR_DB_PATH"; then
        echo "Failed to restore service validator database"
        exit 1
    fi
fi

