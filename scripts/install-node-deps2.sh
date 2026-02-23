#!/bin/bash
# install-node-deps2.sh - Install Frappe Node.js deps with NVM
export HOME=/home/frappe
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
export PATH=$HOME/.nvm/versions/node/v18.20.8/bin:/usr/local/bin:/usr/bin:/bin
export GIT_PYTHON_REFRESH=quiet

BENCH_DIR=/home/frappe/frappe-bench

echo "Node: $(node --version 2>&1)"
echo "npm: $(npm --version 2>&1)"
echo "yarn: $(yarn --version 2>&1)"

echo ""
echo "=== Installing Node modules for frappe app ==="
cd "$BENCH_DIR/apps/frappe"
yarn install 2>&1
echo "Exit: $?"

echo ""
echo "=== bench setup requirements ==="
cd "$BENCH_DIR"
bench setup requirements 2>&1

echo ""
echo "=== Done ==="
