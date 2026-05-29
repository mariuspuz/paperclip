#!/bin/bash
set -euo pipefail

# Only run in remote (web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

INSTALL_DIR="$HOME/.claude/productboard-mcp"
MCP_JSON="$HOME/.claude/mcp.json"

# Clone if not already present
if [ ! -d "$INSTALL_DIR" ]; then
  git clone https://github.com/Enreign/productboard-mcp.git "$INSTALL_DIR"
fi

# Build if dist/index.js is missing
if [ ! -f "$INSTALL_DIR/dist/index.js" ]; then
  cd "$INSTALL_DIR"
  npm install --include=dev
  npm run build
fi

# Write mcp.json — token comes from env var set in settings.local.json
if [ -z "${PRODUCTBOARD_API_TOKEN:-}" ]; then
  echo "WARNING: PRODUCTBOARD_API_TOKEN is not set. Productboard MCP will not be configured." >&2
  exit 0
fi

cat > "$MCP_JSON" <<EOF
{
  "mcpServers": {
    "productboard": {
      "command": "node",
      "args": ["$INSTALL_DIR/dist/index.js"],
      "env": {
        "PRODUCTBOARD_API_TOKEN": "$PRODUCTBOARD_API_TOKEN",
        "LOG_LEVEL": "error"
      }
    }
  }
}
EOF

echo "Productboard MCP configured at $MCP_JSON"
