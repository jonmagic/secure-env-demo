#!/usr/bin/env bash
#
# setup-keychain.sh — Store demo secrets in macOS Keychain.
#
# This stores placeholder secrets in your login keychain so you can
# try the demo immediately. You only need to run this once. After that,
# use with-keychain.sh to inject these secrets into any command.
#
# Each secret is stored as a "generic password" with:
#   - account: your macOS username
#   - service: a namespaced key like "secure-env-demo/api-key"
#
# The -U flag means "update if it already exists."
#
set -euo pipefail

echo "=== macOS Keychain Setup for secure-env-demo ==="
echo ""
echo "This will store demo secrets in your login keychain."
echo ""

store_secret() {
  local service="$1"
  local value="$2"

  if security find-generic-password -a "$USER" -s "$service" -w &>/dev/null; then
    echo "  Already stored: $service. Skipping."
    echo "    To update: security add-generic-password -a \"\$USER\" -s \"$service\" -w \"new-value\" -U"
    return
  fi

  security add-generic-password -a "$USER" -s "$service" -w "$value" -U
  echo "  Stored: $service"
}

store_secret "secure-env-demo/api-key"          "sk-demo-replace-me-with-real-key"
store_secret "secure-env-demo/database-url"     "postgres://user:password@localhost:5432/myapp"
store_secret "secure-env-demo/webhook-secret"   "whsec-demo-replace-me"

echo ""
echo "Done! Demo secrets stored in Keychain."
echo ""
echo "Next steps:"
echo ""
echo "  1. Run the demo:"
echo "     ./with-keychain.sh ./app.sh"
echo ""
echo "  2. Update the secrets with your real values:"
echo "     security add-generic-password -a \"\$USER\" -s \"secure-env-demo/api-key\" -w \"your-real-key\" -U"
