# Demo Script — copy/paste each line in order

# 1. app fails without secrets
./app.sh

# 2. show what a typical .env file looks like
cat .env.example

# 3. 1Password: setup
./setup-1password.sh

# 4. 1Password: show the reference file (safe to commit)
cat .env.1password

# 5. 1Password: run the app with secrets injected
./with-1password.sh ./app.sh

# 6. 1Password: teardown
./teardown-1password.sh

# 7. Keychain: setup
./setup-keychain.sh

# 8. Keychain: run the app with secrets injected
./with-keychain.sh ./app.sh

# 9. Keychain: teardown
./teardown-keychain.sh

# 10. app fails again without the wrapper
./app.sh
