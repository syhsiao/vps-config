#!/bin/bash

# --- System Update and Essential Tools ---
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git curl wget unzip build-essential ripgrep fd-find fzf tmux nodejs npm python3-pip tree

# --- Configure tmux (Classic Mode) ---
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

# --- Set Environment Variables ---
echo 'export PATH="$PATH:/root/.local/share/coursier/bin"' >> /root/.bashrc
echo 'export PATH="$PATH:/root/.local/bin"' >> /root/.bashrc
echo 'export EDITOR=nvim' >> /root/.bashrc
# https://rclone.org/docs/#config-file
echo 'export RCLONE_CONFIG_VULTR_SPACE_ROOT_FOLDER_ID=$MY_RCLONE_ROOT_FOLDER_ID' >> /root/.bashrc

# --- Install Rclone
curl https://rclone.org/install.sh | sudo bash

# --- Install Kickstart.nvim & AI tools & Scala ---
mkdir -p /root/tmp_git
git clone https://github.com/syhsiao/vps-config.git /root/tmp_git
(
  cd /root/tmp_git
  bash ./scripts/install-nvim.sh
  bash ./scripts/install-ai.sh
  bash ./scripts/install-scala.sh
) # Subshell used to keep directory and environment variables unchanged
cp -r /root/tmp_git/.config /root/
rm -rf /root/tmp_git

# --- Pre-install Neovim Plugins (NEW STEP) ---
nvim --headless "+Lazy! sync" +qa

# --- GitHub
git config --file /root/.gitconfig user.name $GITHUB_USER_NAME
git config --file /root/.gitconfig user.email $GITHUB_EMAIL

echo "Kickstart Setup Ready!"
