# secure-env-demo: Demo Script

Run these commands in order while recording. Each section shows the
"before" (broken) and "after" (working) for both approaches.

---

## 1. Show the problem: no secrets, app fails

```bash
./app.sh
```

Expected output: all three variables show as NOT set, script exits with error.

---

## 2. The .env file approach (what most people do)

```bash
cat .env.example
```

Show what a typical .env file looks like. Point out: if you fill this in
and accidentally commit it, your secrets are in git history forever.

---

## 3. 1Password path

### 3a. Setup — create the vault item

```bash
./setup-1password.sh
```

Select your vault when prompted. This creates the item and updates
`.env.1password` with the correct vault references.

### 3b. Show the reference file (safe to commit)

```bash
cat .env.1password
```

Point out: these are `op://` URIs, not actual secrets. This file is
safe to commit to version control.

### 3c. Run the app with secrets injected

```bash
./with-1password.sh ./app.sh
```

Expected output: all three variables show as set with masked values.

### 3d. Teardown (reset for next demo or cleanup)

```bash
./teardown-1password.sh
```

---

## 4. macOS Keychain path

### 4a. Setup — store secrets in Keychain

```bash
./setup-keychain.sh
```

This stores placeholder secrets in your login keychain.

### 4b. Run the app with secrets injected

```bash
./with-keychain.sh ./app.sh
```

Expected output: all three variables show as set with masked values.
macOS may prompt for Keychain access on first use.

### 4c. Teardown (reset for next demo or cleanup)

```bash
./teardown-keychain.sh
```

---

## 5. Show it works with any command

```bash
./with-keychain.sh env | grep -E "API_KEY|DATABASE_URL|WEBHOOK_SECRET"
```

Point out: the wrapper pattern works with any command, not just `app.sh`.

---

## 6. Prove app still fails without the wrapper

```bash
./app.sh
```

Full circle — without the wrapper, no secrets. The app only gets
secrets when you explicitly inject them.
