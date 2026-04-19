#!/bin/bash

# --- 1. System Update and Essential Tools ---
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git curl wget unzip build-essential ripgrep fd-find fzf tmux nodejs npm python3-pip tree

# --- 2. Install Latest Neovim (v0.10+) ---
add-apt-repository ppa:neovim-ppa/unstable -y
apt-get update
apt-get install -y neovim

# --- 3. Install Tree-sitter CLI (For Neovim Highlighting) ---
npm install -g tree-sitter-cli

# --- 4. Install Scala Toolchain (Coursier) ---
curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > cs
chmod +x cs
./cs setup --yes --jvm 21
/cs install metals
mv cs /usr/local/bin/

# --- 5. Install AI CLI Tools ---
# npm install -g @anthropic-ai/claude-code
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g @google/gemini-cli
gemini extensions install https://github.com/gemini-cli-extensions/security --consent
npm install -g drawio-mcp-server
GEMINI_SETTING="/root/.gemini/settings.json"
# Ensure file exists and is not empty
if [ ! -f "$GEMINI_SETTING" ] || [ ! -s "$GEMINI_SETTING" ]; then
    echo "{}" > "$GEMINI_SETTING"
fi
MCP_DRAWIO='{"mcpServers":{"drawio":{"command":"drawio-mcp-server","args":["--editor","--http-port","3000","--extension-port","3333"]}}}'
mcp_tmp=$(mktemp)
jq --argjson new_drawio "$MCP_DRAWIO" '. * $new_drawio' "$GEMINI_SETTING" > "$mcp_tmp" && mv "$mcp_tmp" "$GEMINI_SETTING"

# --- 6. Setup Kickstart.nvim (Single File Config) ---
mkdir -p /root/tmp_git
git clone https://github.com/syhsiao/vps-config.git /root/tmp_git
cp -r /root/tmp_git/.config /root/
rm -rf /root/tmp_git

# --- 7. Configure tmux (Classic Mode) ---
cat <<EOF > /root/.tmux.conf
set -g mouse on
set -g base-index 1
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-h' if-shell "\$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "\$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "\$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "\$is_vim" 'send-keys C-l' 'select-pane -R'

# Change prefix key to Ctrl + a:
# 1. Unbind the default Ctrl + b
unbind C-b      
# 2. Set the new prefix to Ctrl + a
set -g prefix C-a      
# 3. Enable sending Ctrl + a to underlying programs by pressing it twice
# (e.g., to move to the beginning of the line in Bash)
bind C-a send-prefix  
EOF

# --- 8. Set Environment Variables ---
echo 'export PATH="$PATH:/root/.local/share/coursier/bin"' >> /root/.bashrc
echo 'export PATH="$PATH:/root/.local/bin"' >> /root/.bashrc
echo 'export EDITOR=nvim' >> /root/.bashrc

# --- 9. Pre-install Neovim Plugins (NEW STEP) ---
nvim --headless "+Lazy! sync" +qa

# --- 10. GitHub
git config --file /root/.gitconfig user.name $GITHUB_USER_NAME
git config --file /root/.gitconfig user.email $GITHUB_EMAIL

# --- Install Hermes Agent
# To avoid 'uv not found' errors during installation.
export PATH="/root/.local/bin:$PATH"
# Non-interactive installation
export HOME=/root
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash -s -- --skip-setup

echo "Kickstart Setup Ready!"
