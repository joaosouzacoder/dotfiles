return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts = {
            flavour = "mocha", -- ou latte, frappe, macchiato
            transparent_background = true,
            integrations = {
                mason = true,
                treesitter = true,
                telescope = { enabled = true },
                native_lsp = {
                    enabled = true,
                    inlay_hints = { background = true },
                },
                cmp = true,
                gitsigns = true,
                noice = true,
                mini = true,
                notify = true,
                which_key = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)

            -- força transparência após o tema carregar
            -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
}
