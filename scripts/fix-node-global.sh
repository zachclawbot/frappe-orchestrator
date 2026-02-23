#!/bin/bash
# fix-node-global.sh - Make Node 18 accessible system-wide
FRAPPE_NODE_BIN=/home/frappe/.nvm/versions/node/v18.20.8/bin

echo "Making frappe NVM accessible to all users..."
chmod -R 755 /home/frappe/.nvm
chmod -R o+rX /home/frappe/.nvm/versions/node/v18.20.8

# Update /usr/local/bin symlinks to point to frappe's Node 18
ln -sf "$FRAPPE_NODE_BIN/node" /usr/local/bin/node
ln -sf "$FRAPPE_NODE_BIN/npm" /usr/local/bin/npm
ln -sf "$FRAPPE_NODE_BIN/npx" /usr/local/bin/npx
[ -f "$FRAPPE_NODE_BIN/yarn" ] && ln -sf "$FRAPPE_NODE_BIN/yarn" /usr/local/bin/yarn

# Update /usr/bin symlinks
ln -sf /usr/local/bin/node /usr/bin/node
ln -sf /usr/local/bin/node /usr/bin/nodejs
ln -sf /usr/local/bin/npm /usr/bin/npm

echo "Testing node access:"
node --version
npm --version
yarn --version 2>/dev/null || echo "yarn not in /usr/local/bin (OK)"

echo "Testing as frappe user:"
su -l frappe -c "node --version && npm --version"

echo "Done."
