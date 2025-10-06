-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = false })

-- =========================================
-- 🔥 Delete com Black Hole (sem copiar)
-- =========================================

local wk = require("which-key")

wk.add({
  { "<leader>D", group = "🗑 Delete (black hole)" },

  { "<leader>Dd", '"_dd', desc = "Delete line" },
  { "<leader>Dw", '"_dw', desc = "Delete word" },
  { "<leader>Ds", '"_d', mode = "v", desc = "Delete selection" },

  -- 🔽 Delete até o final do arquivo
  { "<leader>De", '"_dG', desc = "🔽 Delete until end of file" },

  -- 🔼 Delete até o início do arquivo
  { "<leader>Di", '"_dgg', desc = "🔼 Delete until start of file" },

  -- 💣 Delete tudo no arquivo
  { "<leader>Da", 'gg"_dG', desc = "💣 Delete entire file" },
})
