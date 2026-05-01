#!/bin/bash

# --- 安裝最新版 Neovim (v0.10+，使用 AppImage 方式) ---
# 原因：使用 AppImage 比 PPA 更穩定，能避免 Launchpad 伺服器連線逾時或 apt 鎖定問題。
# 這樣做可以確保在 GitHub 連線正常的情況下，一定能抓到最新的穩定版本。
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage

# 1. 解壓縮以避免 FUSE 權限問題：
#    在某些雲端虛擬化環境中，AppImage 無法直接掛載執行，解壓後直接跑二進位檔最穩健。
# 2. 使用 > /dev/null (靜音模式)：
#    --appimage-extract 在解壓縮時會列出幾千個檔案路徑。
#    如果不加這行，你的 Startup Script Log 會被這幾千行洗版，變得很難閱讀。
./nvim-linux-x86_64.appimage --appimage-extract > /dev/null

# 3. 確保目標目錄存在且為空（可冪性/Idempotent）：
#    這是為了確保如果這個腳本因為某種原因執行了第二次（例如重新部署或手動修復），
#    它會先清理掉舊的殘留檔案，再放入新的檔案，避免檔案衝突或損壞。
mkdir -p /opt/nvim
rm -rf /opt/nvim/*

# 4. 將解壓後的檔案移至 /opt 並建立軟連結：
#    將其路徑加入 /usr/local/bin，使其執行優先級高於原本系統內建的舊版 (/usr/bin/nvim)。
cp -r squashfs-root/* /opt/nvim/
ln -sf /opt/nvim/AppRun /usr/local/bin/nvim

# 5. 清理環境 (rm -rf squashfs-root)：
#    AppImage 解壓縮後會產生一個很大的暫存資料夾 squashfs-root，
#    安裝完成後將其刪除，可以保持機器的磁碟空間乾淨，不留垃圾。
rm -rf squashfs-root nvim-linux-x86_64.appimage

# --- Install Tree-sitter CLI (For Neovim Highlighting) ---
npm install -g tree-sitter-cli
