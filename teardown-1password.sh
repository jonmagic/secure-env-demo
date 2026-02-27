#!/usr/bin/env bash
#
# teardown-1password.sh — Remove the demo item from 1Password.
#
# This deletes the "secure-env-demo" item from the vault referenced
# in .env.1password and resets .env.1password to its default state.
#
# Usage:
#   ./teardown-1password.sh
#
set -euo pipefail

ITEM="secure-env-demo"
ENV_FILE=".env.1password"

if ! command -v op &> /dev/null; then
  echo "Error: 1Password CLI (op) is not installed."
  exit 1
fi

# Read the vault name from .env.1password
VAULT=""
if [ -f "$ENV_FILE" ]; then
  # Extract vault name from first op:// reference
  VAULT=$(grep -m1 'op://' "$ENV_FILE" | sed 's|.*op://\([^/]*\)/.*|\1|')
fi

if [ -z "$VAULT" ] || [ "$VAULT" = "VAULT_NAME" ]; then
  echo "Error: No vault configured. Nothing to tear down."
  exit 0
fi

echo "Removing '$ITEM' from vault '$VAULT'..."

if op item get "$ITEM" --vault="$VAULT" &> /dev/null; then
  op item delete "$ITEM" --vault="$VAULT"
  echo "  Deleted item from 1Password."
else
  echo "  Item not found in 1Password. Already removed?"
fi

# Reset .env.1password to default
cat > "$ENV_FILE" <<'EOF'
# 1Password secret references -- safe to commit!
# These URIs are resolved at runtime by `op run`.
# Run ./setup-1password.sh to configure your vault and update this file.

API_KEY=op://VAULT_NAME/secure-env-demo/api-key
DATABASE_URL=op://VAULT_NAME/secure-env-demo/database-url
WEBHOOK_SECRET=op://VAULT_NAME/secure-env-demo/webhook-secret
EOF

echo "  Reset $ENV_FILE to defaults."
echo ""
echo "Done! Run ./setup-1password.sh to set it up again."
