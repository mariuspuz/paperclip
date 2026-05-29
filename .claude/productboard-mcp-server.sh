#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.claude/productboard-mcp"

# Clone if not present
if [ ! -d "$INSTALL_DIR" ]; then
  git clone https://github.com/Enreign/productboard-mcp.git "$INSTALL_DIR" >&2
fi

# Build if dist/index.js is missing
if [ ! -f "$INSTALL_DIR/dist/index.js" ]; then
  cd "$INSTALL_DIR"
  npm install --include=dev >&2
  npm run build >&2
fi

exec node "$INSTALL_DIR/dist/index.js"
