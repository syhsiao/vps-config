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
npm install -g @anthropic-ai/claude-code
pip3 install -q -U google-generativeai

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
EOF

# --- 8. Set Environment Variables ---
echo 'export ANTHROPIC_API_KEY="YOUR_KEY_HERE"' >> /root/.bashrc
echo 'export GOOGLE_API_KEY="YOUR_KEY_HERE"' >> /root/.bashrc
echo 'export PATH="$PATH:/root/.local/share/coursier/bin"' >> /root/.bashrc
echo 'export EDITOR=nvim' >> /root/.bashrc

# --- 9. Pre-install Neovim Plugins (NEW STEP) ---
nvim --headless "+Lazy! sync" +qa

echo "Kickstart Setup Ready!"
