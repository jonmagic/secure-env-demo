#!/usr/bin/env bash
#
# with-keychain.sh — Inject secrets from macOS Keychain and run a command.
#
# Prerequisites:
#   Store each secret in Keychain using the `security` command:
#
#     security add-generic-password -a "$USER" -s "secure-env-demo/api-key" \
#       -w "sk-your-actual-api-key" -U
#
#   See setup-keychain.sh for a guided setup, or README.md for details.
#
# Usage:
#   ./with-keychain.sh ./app.sh
#   ./with-keychain.sh node server.js
#   ./with-keychain.sh -- pytest
#
# How it works:
#   For each variable listed below, the script reads the corresponding
#   value from macOS Keychain using `security find-generic-password`,
#   exports it as an environment variable, and then execs your command.
#   Secrets never touch disk as plaintext.
#
#   macOS may prompt for Keychain access (password or Touch ID) on
#   first use, then caches approval for the terminal session.
#
set -euo pipefail

if ! command -v security &> /dev/null; then
  echo "Error: 'security' command not found. This script requires macOS."
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: ./with-keychain.sh <command> [args...]"
  echo ""
  echo "Examples:"
  echo "  ./with-keychain.sh ./app.sh"
  echo "  ./with-keychain.sh node server.js"
  exit 1
fi

# Strip leading -- if present
if [ "$1" = "--" ]; then
  shift
fi

# Read a secret from Keychain or exit with a helpful error.
read_secret() {
  local var="$1"
  local service="$2"
  local value

  value=$(security find-generic-password -a "$USER" -s "$service" -w 2>/dev/null) || {
    echo "Error: Could not read '$service' from Keychain."
    echo ""
    echo "Store it with:"
    echo "  security add-generic-password -a \"\$USER\" -s \"$service\" -w \"your-value\" -U"
    echo ""
    echo "Or run: ./setup-keychain.sh"
    exit 1
  }

  export "$var=$value"
}

# Add new secrets by adding a read_secret line below.
read_secret API_KEY          "secure-env-demo/api-key"
read_secret DATABASE_URL     "secure-env-demo/database-url"
read_secret WEBHOOK_SECRET   "secure-env-demo/webhook-secret"

exec "$@"
