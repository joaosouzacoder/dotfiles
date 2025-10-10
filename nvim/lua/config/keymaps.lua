local util = require("util")

util.cowboy()
-- util.wezterm()
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = false })

if vim.g.vscode then
    vim.keymap.set("n", "<leader>ff", function()
        require("vscode").action("workbench.action.quickOpen")
    end)
    vim.keymap.set("n", "<leader>e", function()
        require("vscode").action("workbench.view.explorer")
    end, { desc = "Open Explorer in VSCode" })

    vim.keymap.set("n", "<leader>gg", function()
        require("vscode").action("workbench.view.scm")
    end, { desc = "Open Source Control in VSCode" })
end
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

vim.keymap.set("n", "<C-c>", "ciw")
vim.keymap.set("n", "<Up>", "<c-w>k")
vim.keymap.set("n", "<Down>", "<c-w>j")
vim.keymap.set("n", "<Left>", "<c-w>h")
vim.keymap.set("n", "<Right>", "<c-w>l")
