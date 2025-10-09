-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = false })

-- =========================================
-- 🔥 Delete com Black Hole (sem copiar)
-- =========================================
local ok, wk = pcall(require, "which-key")
if not ok then
  return
end

wk.add({
  { "<leader>D", group = "🗑 Delete (black hole)" },

  { "<leader>Dd", '"_dd', desc = "Delete line" },
  { "<leader>Dw", '"_dw', desc = "Delete word" },
  { "<leader>Ds", '"_d', mode = "v", desc = "Delete selection" },

  { "<leader>De", '"_dG', desc = "🔽 Delete until end of file" },
  { "<leader>Di", '"_dgg', desc = "🔼 Delete until start of file" },
  { "<leader>Da", 'gg"_dG', desc = "💣 Delete entire file" },
})
