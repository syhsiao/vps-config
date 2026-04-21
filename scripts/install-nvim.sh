#!/bin/bash

# --- Install Latest Neovim (v0.10+) ---
add-apt-repository ppa:neovim-ppa/unstable -y
apt-get update
apt-get install -y neovim

# --- Install Tree-sitter CLI (For Neovim Highlighting) ---
npm install -g tree-sitter-cli