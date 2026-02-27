#!/usr/bin/env bash
#
# with-1password.sh — Inject secrets from 1Password and run a command.
#
# Prerequisites:
#   1. Install 1Password CLI: https://developer.1password.com/docs/cli/get-started
#   2. Sign in: `op signin`
#   3. Create a vault item (see setup-1password.sh or README.md)
#
# Usage:
#   ./with-1password.sh ./app.sh
#   ./with-1password.sh node server.js
#   ./with-1password.sh -- pytest
#
# How it works:
#   `op run` reads .env.1password, resolves each op:// reference by
#   fetching the secret from your 1Password vault, and injects the
#   resolved values as environment variables into the subprocess.
#   Secrets never touch disk as plaintext. op also automatically masks
#   secret values if they appear in stdout/stderr.
#
set -euo pipefail

ENV_FILE=".env.1password"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found."
  echo "Copy .env.1password.example and customize the vault/item references."
  exit 1
fi

if ! command -v op &> /dev/null; then
  echo "Error: 1Password CLI (op) is not installed."
  echo "Install it: https://developer.1password.com/docs/cli/get-started"
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: ./with-1password.sh <command> [args...]"
  echo ""
  echo "Examples:"
  echo "  ./with-1password.sh ./app.sh"
  echo "  ./with-1password.sh node server.js"
  exit 1
fi

# Strip leading -- if present (allows: ./with-1password.sh -- mycommand)
if [ "$1" = "--" ]; then
  shift
fi

exec op run --env-file="$ENV_FILE" -- "$@"
