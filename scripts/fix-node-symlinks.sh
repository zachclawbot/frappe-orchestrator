#!/bin/bash
# fix-node-symlinks.sh - Make /usr/bin/node point to Node 18
NODE18=/usr/local/bin/node
echo "Node 18 at: $NODE18"
echo "Version: $($NODE18 --version)"

# Replace system node symlinks
mv /usr/bin/node /usr/bin/node12 2>/dev/null || true
mv /usr/bin/nodejs /usr/bin/nodejs12 2>/dev/null || true
ln -sf "$NODE18" /usr/bin/node
ln -sf "$NODE18" /usr/bin/nodejs

# Link npm and yarn too
NPM18=/usr/local/bin/npm
YARN18=/usr/local/bin/yarn
[ -f "$NPM18" ] && ln -sf "$NPM18" /usr/bin/npm
[ -f "$YARN18" ] && ln -sf "$YARN18" /usr/bin/yarn

echo "Final check:"
which node && node --version
which npm && npm --version
which yarn && yarn --version
