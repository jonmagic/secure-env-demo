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
#   ./setup-1password.sh              # uses vault from .env.1password
#   ./setup-1password.sh "My Vault"   # specify vault directly
#
set -euo pipefail

ITEM="secure-env-demo"
ENV_FILE=".env.1password"

if ! command -v op &> /dev/null; then
  echo "Error: 1Password CLI (op) is not installed."
  echo "Install it: https://developer.1password.com/docs/cli/get-started"
  exit 1
fi

# Determine which vault to use: argument > .env.1password > error
if [ $# -ge 1 ]; then
  VAULT="$1"
elif [ -f "$ENV_FILE" ]; then
  VAULT=$(grep -m1 'op://' "$ENV_FILE" | sed 's|.*op://\([^/]*\)/.*|\1|')
fi

if [ -z "${VAULT:-}" ]; then
  echo "Error: Could not determine vault name."
  echo "Either pass it as an argument or set it in $ENV_FILE."
  exit 1
fi

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

echo ""
echo "Done! Item created in vault '$VAULT'."
echo ""
echo "Run the demo:"
echo "  ./with-1password.sh ./app.sh"
