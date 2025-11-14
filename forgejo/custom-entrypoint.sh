#!/bin/bash
set -euo pipefail

DATA_DIR=/data/gitea
CONFIG="$DATA_DIR/conf/app.ini"
DB_FILE="$DATA_DIR/forgejo.db"

# Create directories if they do not exist
mkdir -p "$DATA_DIR/conf"
mkdir -p "$DATA_DIR/repositories"
mkdir -p "$DATA_DIR/lfs"
mkdir -p "$DATA_DIR/log"
chown -R git:git "/data"

# Copy app.ini only if it does not already exist
if [ ! -f "$CONFIG" ]; then
    echo "Copying app.ini..."
    cp /tmp/app.ini "$CONFIG"
    chown git:git "$CONFIG"
fi

# Run migration if the database does not exist
if [ ! -f "$DB_FILE" ]; then
    echo "Database does not exist, running migration..."
    su-exec git /usr/local/bin/gitea \
        --config "$CONFIG" \
        --work-path "$DATA_DIR" migrate
fi

# Start Forgejo in the background
/usr/bin/entrypoint &
FORGEJO_PID=$!

# Wait for Forgejo HTTP service to become available (verbose)
echo "Waiting for Forgejo HTTP service..."
MAX_TRIES=30
TRIES=0
until curl -s http://127.0.0.1:3000 >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ $TRIES -ge $MAX_TRIES ]; then
    echo "Forgejo failed to start!" >&2
    exit 1
  fi
  echo "Forgejo not ready yet, waiting... ($TRIES/$MAX_TRIES)"
  sleep 2
done

# Initialize users if not already done
if [ ! -f "$DATA_DIR/.users_initialized" ]; then
    echo "Initializing users..."
    /usr/local/bin/create-users.sh "$CONFIG" 10
    touch "$DATA_DIR/.users_initialized"
fi

# Create token if not already done
if [ ! -f "$DATA_DIR/.token_generated" ]; then
    echo "Creating token..."
    /usr/local/bin/create-token.sh
    touch "$DATA_DIR/.token_generated"
fi

# Keep Forgejo running in the foreground
echo "Forgejo is ready."
wait $FORGEJO_PID
