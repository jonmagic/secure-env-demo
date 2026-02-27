#!/usr/bin/env bash
#
# setup-1password.sh — Create a 1Password vault item for this demo.
#
# This creates an item in your 1Password vault with placeholder secrets.
# You only need to run this once. After that, use with-1password.sh to
# inject these secrets into any command.
#
# Prerequisites:
#   1. Install 1Password CLI: https://developer.1password.com/docs/cli/get-started
#   2. Sign in: `op signin`
#
# Usage:
#   ./setup-1password.sh              # interactive vault selection
#   ./setup-1password.sh "My Vault"   # specify vault directly
#
set -euo pipefail

ITEM="secure-env-demo"

if ! command -v op &> /dev/null; then
  echo "Error: 1Password CLI (op) is not installed."
  echo "Install it: https://developer.1password.com/docs/cli/get-started"
  exit 1
fi

# Determine which vault to use
if [ $# -ge 1 ]; then
  VAULT="$1"
else
  echo "=== 1Password Setup for secure-env-demo ==="
  echo ""
  echo "Available vaults:"
  echo ""

  # List vaults (compatible with bash 3.2 — no mapfile)
  vault_json=$(op vault list --format=json)

  if command -v jq &> /dev/null; then
    vault_list=$(echo "$vault_json" | jq -r '.[].name')
  else
    vault_list=$(echo "$vault_json" | python3 -c "import sys,json; [print(v['name']) for v in json.load(sys.stdin)]")
  fi

  # Read into a numbered list
  count=0
  while IFS= read -r name; do
    count=$((count + 1))
    eval "vault_$count=\"$name\""
    echo "  $count. $name"
  done <<< "$vault_list"

  if [ "$count" -eq 0 ]; then
    echo "Error: No vaults found. Are you signed in? Try: op signin"
    exit 1
  fi

  echo ""
  printf "Select a vault (1-%s): " "$count"
  read -r choice

  if ! echo "$choice" | grep -qE '^[0-9]+$' || [ "$choice" -lt 1 ] || [ "$choice" -gt "$count" ]; then
    echo "Invalid selection."
    exit 1
  fi

  eval "VAULT=\$vault_$choice"
fi

echo ""
echo "Using vault: $VAULT"
echo ""

# Check if item already exists
if op item get "$ITEM" --vault="$VAULT" &> /dev/null; then
  echo "Item '$ITEM' already exists in vault '$VAULT'."
  echo "To update it, edit the item in 1Password or delete and re-run:"
  echo "  op item delete '$ITEM' --vault='$VAULT'"
  exit 0
fi

op item create \
  --category=login \
  --title="$ITEM" \
  --vault="$VAULT" \
  "api-key[password]=sk-demo-replace-me-with-real-key" \
  "database-url[password]=postgres://user:password@localhost:5432/myapp" \
  "webhook-secret[password]=whsec-demo-replace-me"

# Update .env.1password with the selected vault name
ENV_FILE=".env.1password"
cat > "$ENV_FILE" <<EOF
# 1Password secret references -- safe to commit!
# These URIs are resolved at runtime by \`op run\`.
# Re-run setup-1password.sh to change the vault.

API_KEY=op://$VAULT/$ITEM/api-key
DATABASE_URL=op://$VAULT/$ITEM/database-url
WEBHOOK_SECRET=op://$VAULT/$ITEM/webhook-secret
EOF

echo ""
echo "Done! Item created in vault '$VAULT'."
echo "Updated $ENV_FILE with your vault name."
echo ""
echo "Next steps:"
echo ""
echo "  1. Run the demo:"
echo "     ./with-1password.sh ./app.sh"
echo ""
echo "  2. Edit the secrets in 1Password to use your real values."
