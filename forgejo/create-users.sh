#!/bin/bash
set -euo pipefail


CONFIG="${1:-/data/gitea/conf/app.ini}"
USER_COUNT="${2:-20}"
FORGEJO_BIN="/usr/local/bin/gitea"
USER="git"


echo "------------------------------------"
echo " Starting user creation"
echo " Config file: $CONFIG"
echo " Number of students: $USER_COUNT"
echo "------------------------------------"


echo "Creating admin user 'root'..."
su-exec "$USER" "$FORGEJO_BIN" --config "$CONFIG" admin user create \
    --username root \
    --password root123 \
    --email root@example.com \
    --admin \
    --must-change-password=false \
    >/dev/null 2>&1 || echo "Admin user 'root' already exists."


echo "Creating teacher user..."
su-exec "$USER" "$FORGEJO_BIN" --config "$CONFIG" admin user create \
    --username teacher \
    --password teacher123 \
    --email teacher@example.com \
    --must-change-password=false \
    >/dev/null 2>&1 || echo "Teacher user already exists."


for i in $(seq 1 "$USER_COUNT"); do
    USERNAME="student${i}"
    PASSWORD="student${i}123"
    EMAIL="student${i}@example.com"

    echo "Creating user '$USERNAME'..."
    su-exec "$USER" "$FORGEJO_BIN" --config "$CONFIG" admin user create \
        --username "$USERNAME" \
        --password "$PASSWORD" \
        --email "$EMAIL" \
        --must-change-password=false \
        >/dev/null 2>&1 || echo "User '$USERNAME' already exists."
done


echo "User creation complete."
