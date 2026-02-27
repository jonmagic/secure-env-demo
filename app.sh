#!/usr/bin/env bash
#
# app.sh — A simple script that uses environment variables.
#
# This represents any application, script, or tool that needs
# secrets from the environment. It never loads a .env file itself.
# Instead, secrets are injected by the caller.
#
# Usage (INSECURE - don't do this):
#   API_KEY=sk-1234 DATABASE_URL=postgres://... ./app.sh
#
# Usage (SECURE - do this instead):
#   ./with-1password.sh ./app.sh
#   ./with-keychain.sh ./app.sh
#
set -euo pipefail

echo "=== secure-env-demo ==="
echo ""
echo "Checking for required environment variables..."
echo ""

missing=0

for var in API_KEY DATABASE_URL WEBHOOK_SECRET; do
  if [ -z "${!var:-}" ]; then
    echo "  ✗ $var is NOT set"
    missing=1
  else
    # Show first 4 chars, mask the rest
    value="${!var}"
    if [ ${#value} -gt 4 ]; then
      echo "  ✓ $var = ${value:0:4}••••••••"
    else
      echo "  ✓ $var = ••••"
    fi
  fi
done

echo ""

if [ $missing -eq 1 ]; then
  echo "Some variables are missing. See README.md for setup instructions."
  exit 1
else
  echo "All secrets loaded securely. Your app is ready to go."
fi
