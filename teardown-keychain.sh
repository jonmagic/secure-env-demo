#!/usr/bin/env bash
#
# teardown-keychain.sh — Remove demo secrets from macOS Keychain.
#
# This deletes the "secure-env-demo/*" entries that were created
# by setup-keychain.sh.
#
# Usage:
#   ./teardown-keychain.sh
#
set -euo pipefail

echo "=== Removing secure-env-demo secrets from Keychain ==="
echo ""

remove_secret() {
  local service="$1"

  if security find-generic-password -a "$USER" -s "$service" &>/dev/null; then
    security delete-generic-password -a "$USER" -s "$service" &>/dev/null
    echo "  Deleted: $service"
  else
    echo "  Not found: $service (already removed?)"
  fi
}

remove_secret "secure-env-demo/api-key"
remove_secret "secure-env-demo/database-url"
remove_secret "secure-env-demo/webhook-secret"

echo ""
echo "Done! Run ./setup-keychain.sh to set it up again."
