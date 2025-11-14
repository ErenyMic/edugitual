#!/bin/bash
set -euo pipefail

FORGEJO_URL="http://localhost:3000"
TOKEN_FILE="/data/token.env"

echo "Creating API token..."

RESPONSE=$(curl -sf -X POST -u root:root123 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "edugitual-poc",
    "scopes": [
      "write:admin",
      "read:admin",
      "write:repository",
      "read:repository",
      "write:user",
      "read:user"
    ]
  }' \
  "$FORGEJO_URL/api/v1/users/root/tokens")

ADMIN_TOKEN=$(echo "$RESPONSE" | jq -r '.sha1')
echo "FORGEJO_ADMIN_TOKEN=$ADMIN_TOKEN" > "$TOKEN_FILE"

echo "Token created: $ADMIN_TOKEN"
