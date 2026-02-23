#!/bin/bash
# fix-nodejs-nvm.sh - Install Node.js 18 via NVM (most reliable method)
export DEBIAN_FRONTEND=noninteractive

echo "=== Installing NVM ==="
# Install NVM for root 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash 2>&1

# Source NVM
export NVM_DIR="/root/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

echo "=== Installing Node.js 18 via NVM ==="
nvm install 18 2>&1
nvm use 18 2>&1
nvm alias default 18 2>&1

echo "=== Node version after NVM ==="
node --version
npm --version

# Create symlinks so node/npm/yarn are globally accessible
NODE_PATH=$(which node)
NPM_PATH=$(which npm)

ln -sf "$NODE_PATH" /usr/local/bin/node 2>/dev/null || true
ln -sf "$NPM_PATH" /usr/local/bin/npm 2>/dev/null || true

echo "=== Installing yarn ==="
npm install -g yarn 2>&1
YARN_PATH=$(which yarn 2>/dev/null || nvm exec 18 which yarn 2>/dev/null)
[ -n "$YARN_PATH" ] && ln -sf "$YARN_PATH" /usr/local/bin/yarn 2>/dev/null || true

echo "=== Final versions ==="
/usr/local/bin/node --version 2>/dev/null || node --version
/usr/local/bin/npm --version 2>/dev/null || npm --version
/usr/local/bin/yarn --version 2>/dev/null || yarn --version

# Install for frappe user too
echo "=== Installing NVM for frappe user ==="
sudo -u frappe -H bash -c "
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash 2>&1
    export NVM_DIR=/home/frappe/.nvm
    [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
    nvm install 18 2>&1
    nvm use 18 2>&1
    nvm alias default 18 2>&1
    echo 'frappe node:' \$(node --version 2>&1)
    npm install -g yarn 2>&1
    echo 'frappe yarn:' \$(yarn --version 2>&1)
" 2>&1

# Add NVM to frappe's .bashrc
cat >> /home/frappe/.bashrc << 'BASHEOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export GIT_PYTHON_REFRESH=quiet
BASHEOF

chown frappe:frappe /home/frappe/.bashrc

echo "=== Done ==="
