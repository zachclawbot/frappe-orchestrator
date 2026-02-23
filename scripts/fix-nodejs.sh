#!/bin/bash
# fix-nodejs.sh - Installs Node.js 18 and yarn properly
export DEBIAN_FRONTEND=noninteractive

echo "=== Removing old Node.js ==="
apt-get remove -y nodejs npm 2>&1 || true
apt-get autoremove -y 2>&1 || true

echo "=== Installing Node.js 18 via NodeSource ==="
curl -fsSL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh 2>&1
apt-get install -y nodejs 2>&1

echo "=== Node.js version check ==="
node --version
npm --version

echo "=== Installing yarn ==="
npm install -g yarn 2>&1
yarn --version

echo "=== Fixing ownership ==="
chown -R frappe:frappe /home/frappe 2>/dev/null || true

echo "=== Done ==="
