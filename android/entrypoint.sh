#!/bin/bash
set -e

echo "Fixing volume permissions..."

# Fix permissions for mounted volumes if they exist and are owned by root
fix_permissions() {
    local dir=$1
    if [ -d "$dir" ] && [ "$(stat -c '%u' "$dir" 2>/dev/null || echo 0)" = "0" ]; then
        echo "  → Fixing $dir (owned by root)"
        # We need to run this as root first, then switch to dev user
        sudo chown -R dev:dev "$dir" 2>/dev/null || true
    fi
}

# Check and fix common mount points
fix_permissions "/home/dev/.gradle"
fix_permissions "/app/src/.gradle"
fix_permissions "/app/build"

echo "✓ Permissions fixed"

# Execute the command passed to docker run
exec "$@"