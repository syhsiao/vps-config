return {
  -- tmux integration
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },
  -- Scala Metals Support
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim", -- 許多插件必備的 Lua 工具庫 
      "mfussenegger/nvim-dap"  -- Debug 適配器協議，用於斷點偵錯 (Debugging)
    },
    ft = { "scala", "sbt", "java" },
    config = function() -- 插件載入後的設定函式
      local metals_config = require("metals").bare_config() -- 取得 Metals 的基礎預設設定
      -- Explicitly set binary path to bypass "Metals not installed" warning and fix PATH synchronization issues.
      metals_config.settings = {
        -- 避免 nvim 找不到 coursier 安裝的路徑
        metalsBinaryPath = "/root/.local/share/coursier/bin/metals",
      }
      metals_config.on_attach = function(client, bufnr)
        -- 當 Metals LSP 成功連線到當前檔案時，執行此函式
        require("metals").setup_dap() -- 啟動 Debug 支援，讓你可以在 Scala 代碼跑斷點
      end
      -- 建立一個自動命令組 (Autocmd Group)，避免重複定義
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      -- 建立自動命令：當檔案類型 (FileType) 是 scala 或 sbt 時
      vim.api.nvim_create_autocmd("FileType", {
        group = nvim_metals_group,
        pattern = { "scala", "sbt" },
        callback = function()
          -- 執行初始化或附加到已存在的 Metals Server
          require("metals").initialize_or_attach(metals_config)
        end,
      })
    end,
  },
}
