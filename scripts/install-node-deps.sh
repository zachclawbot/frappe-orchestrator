#!/bin/bash
# install-node-deps.sh - Install Node.js dependencies for Frappe
export HOME=/home/frappe
export PATH=/home/frappe/.local/bin:/usr/local/bin:/usr/bin:/bin

echo "Node.js: $(node --version 2>&1)"
echo "npm: $(npm --version 2>&1)"

# Install yarn globally if missing  
if ! command -v yarn &>/dev/null; then
    echo "Installing yarn..."
    npm install -g yarn 2>&1
fi
echo "yarn: $(yarn --version 2>&1)"

BENCH_DIR=/home/frappe/frappe-bench

echo ""
echo "=== Installing Node modules for frappe ==="
cd "$BENCH_DIR/apps/frappe"
yarn install 2>&1
echo "Exit: $?"

echo ""
echo "=== Running bench setup requirements ==="
cd "$BENCH_DIR"
bench setup requirements 2>&1

echo ""
echo "=== Done ==="
