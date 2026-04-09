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

# 將前綴鍵改為 Ctrl + a:      
# 1. 取消原本的 Ctrl + b 綁定      
unbind C-b      
# 2. 設定新的前綴鍵為 Ctrl + a      
set -g prefix C-a      
# 3. 確保按兩次 Ctrl + a 可以把這個按鍵傳送給內層程式 (例如在 Bash 跳到行首)                                           
bind C-a send-prefix  
EOF

# --- 8. Set Environment Variables ---
echo 'export ANTHROPIC_API_KEY="YOUR_KEY_HERE"' >> /root/.bashrc
echo 'export GEMINI_API_KEY="YOUR_KEY_HERE"' >> /root/.bashrc
echo 'export PATH="$PATH:/root/.local/share/coursier/bin"' >> /root/.bashrc
echo 'export EDITOR=nvim' >> /root/.bashrc

# --- 9. Pre-install Neovim Plugins (NEW STEP) ---
nvim --headless "+Lazy! sync" +qa

# --- 10. GitHub
git config --file /root/.gitconfig user.name $GITHUB_USER_NAME
git config --file /root/.gitconfig user.email $GITHUB_EMAIL

echo "Kickstart Setup Ready!"
