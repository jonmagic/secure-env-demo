# secure-env-demo

Stop storing secrets in `.env` files. This repo demonstrates two approaches to securely injecting secrets into your development workflow without ever writing plaintext credentials to disk.

Both approaches follow the same pattern: **store secrets in a secure vault, inject them at runtime.**

## Demo

https://github.com/jonmagic/secure-env-demo/raw/main/secure-env-demo.mp4

## The Problem

```bash
# This is what most of us do. It's convenient. It's also dangerous.
echo "API_KEY=sk-1234567890" >> .env
```

`.env` files seem harmless, but they're plaintext files sitting in your project directory. They get accidentally committed to git. They get copied into Slack messages. They pile up across dozens of projects with stale credentials that never get rotated.

## The Pattern

Instead of storing secrets in files, use a **wrapper script** that fetches secrets from a secure store and injects them as environment variables into your process:

```bash
# Instead of:  source .env && ./app.sh
# Do this:
./with-1password.sh ./app.sh    # secrets from 1Password
./with-keychain.sh ./app.sh     # secrets from macOS Keychain
```

Your app doesn't change at all. It reads `process.env.API_KEY` or `$API_KEY` the same way it always did. The difference is where the values come from.

## Quick Start

### Option A: 1Password CLI

**Prerequisites:** [1Password CLI](https://developer.1password.com/docs/cli/get-started) installed and signed in.

```bash
# 1. Create a vault item with your secrets
./setup-1password.sh

# 2. Edit .env.1password to match your vault/item names (defaults work with setup script)

# 3. Run any command with secrets injected
./with-1password.sh ./app.sh
```

**How it works:** The file `.env.1password` contains secret *references* like `op://Development/secure-env-demo/api-key` instead of actual values. The `op run` command resolves each reference at runtime, fetching the real value from your vault. The `.env.1password` file is safe to commit — it contains no secrets.

### Option B: macOS Keychain

**Prerequisites:** macOS (uses the built-in `security` command).

```bash
# 1. Store your secrets in Keychain
./setup-keychain.sh

# 2. Run any command with secrets injected
./with-keychain.sh ./app.sh
```

**How it works:** Each secret is stored as a "generic password" in your login keychain, namespaced under `secure-env-demo/`. The wrapper script reads each value using `security find-generic-password` and exports it before running your command. macOS may prompt for Keychain access (password or Touch ID) on first use.

## What's in This Repo

```
.env.example        # Documents which variables are needed (no real values)
.env.1password      # Secret references for 1Password (safe to commit)
.gitignore          # Ensures .env files with real values are never committed

app.sh              # Demo app that checks for required environment variables
with-1password.sh   # Wrapper: inject secrets from 1Password, run a command
with-keychain.sh    # Wrapper: inject secrets from macOS Keychain, run a command
setup-1password.sh  # One-time setup: create vault item in 1Password
setup-keychain.sh   # One-time setup: store secrets in macOS Keychain
```

## Adapting This for Your Projects

The wrapper scripts work with any command, not just `app.sh`:

```bash
./with-1password.sh node server.js
./with-1password.sh python manage.py runserver
./with-1password.sh -- pytest
./with-keychain.sh docker compose up
```

To add a new secret:

1. Add the variable to `.env.example` for documentation
2. **1Password:** Add a field to your vault item, add a reference to `.env.1password`
3. **Keychain:** Run `security add-generic-password -a "$USER" -s "secure-env-demo/my-new-secret" -w "value" -U` and add the mapping to the `SECRETS` array in `with-keychain.sh`

## Why Not Just Use .gitignore?

`.gitignore` is a safety net, not a strategy. It only protects one repo. It doesn't help when:

- Someone copies the `.env` file to a colleague over Slack
- You have 30 projects each with their own `.env` file containing the same API key
- A credential gets rotated and you have to find and update every copy
- You need to audit who has access to which secrets

A secrets manager gives you one source of truth, access control, and (with 1Password or Vault) an audit trail.

## Further Reading

- [1Password CLI: Secret References](https://developer.1password.com/docs/cli/secret-references/)
- [1Password CLI: Secrets in Scripts](https://developer.1password.com/docs/cli/secrets-scripts/)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

## License

ISC
