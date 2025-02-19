# only set these if they arent set in the environment
if [ -z "$COLLECTOR_BACKUP_BASE_URL" ]; then
    export COLLECTOR_BACKUP_BASE_URL="https://storage.googleapis.com/ldrpc-seed-data/itn4/collector"
fi
if [ -z "$SERVICE_VALIDATOR_BACKUP_BASE_URL" ]; then
    export SERVICE_VALIDATOR_BACKUP_BASE_URL="https://storage.googleapis.com/ldrpc-seed-data/itn4/shardeum"
fi

get_date_str() {
    local days_ago=$1
    date -d "$days_ago days ago" +%Y%m%d
}

try_backup() {
    local date_str="$1"
    local base_url="$2"
    local target_path="$3"
    local backup_url="${base_url}.${date_str}.tgz"
    
    echo "Downloading backup from ${date_str} at ${backup_url}"
    if curl --retry 3 --retry-delay 2 -sL "${backup_url}" | tar -xz -O > "${target_path}"; then
        return 0
    fi
    return 1
}

try_backups_for_days() {
    local base_url="$1"
    local target_path="$2"
    local days=30
    
    for i in $(seq 0 $((days-1))); do
        local date_str=$(get_date_str $i)
        if try_backup "$date_str" "$base_url" "$target_path"; then
            echo "Successfully restored backup from ${date_str}"
            return 0
        fi
        echo "Backup from ${date_str} unavailable, trying previous day..."
    done
    return 1
}

# if we have a collector database already dont restore it
if [ ! -f "$COLLECTOR_DB_PATH" ]; then
    echo "Restoring collector database at $COLLECTOR_DB_PATH"
    if ! try_backups_for_days "$COLLECTOR_BACKUP_BASE_URL" "$COLLECTOR_DB_PATH"; then
        echo "Failed to restore collector database after trying last ${days} days"
        exit 1
    fi
fi

# if we have a service validator database already dont restore it
if [ ! -f "$SERVICE_VALIDATOR_DB_PATH" ]; then
    echo "Restoring service validator database at $SERVICE_VALIDATOR_DB_PATH"
    if ! try_backups_for_days "$SERVICE_VALIDATOR_BACKUP_BASE_URL" "$SERVICE_VALIDATOR_DB_PATH"; then
        echo "Failed to restore service validator database after trying last ${days} days"
        exit 1
    fi
fi

