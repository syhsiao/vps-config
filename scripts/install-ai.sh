#!/bin/bash

# --- Install AI CLI Tools ---
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g @google/gemini-cli
# Install Gemini CLI Security Extension
gemini extensions install https://github.com/gemini-cli-extensions/security --consent
# Instal draw.io MCP server
# https://github.com/lgazo/drawio-mcp-server
npm install -g drawio-mcp-server
GEMINI_SETTING="/root/.gemini/settings.json"
# Ensure file exists and is not empty
if [ ! -f "$GEMINI_SETTING" ] || [ ! -s "$GEMINI_SETTING" ]; then
    echo "{}" > "$GEMINI_SETTING"
fi
MCP_DRAWIO='{"mcpServers":{"drawio":{"command":"drawio-mcp-server","args":["--editor","--http-port","3000","--extension-port","3333"]}}}'
mcp_tmp=$(mktemp)
jq --argjson new_drawio "$MCP_DRAWIO" '. * $new_drawio' "$GEMINI_SETTING" > "$mcp_tmp" && mv "$mcp_tmp" "$GEMINI_SETTING"

# --- Install Hermes Agent
export HOME=/root
# To avoid 'uv not found' errors during installation.
export PATH="/root/.local/bin:$PATH"
# Non-interactive installation
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash -s -- --skip-setup