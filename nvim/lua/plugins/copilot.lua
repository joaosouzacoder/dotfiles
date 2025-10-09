return {
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_auto_trigger = true
      vim.g.copilot_suggestion_auto_trigger = true
      vim.g.copilot_suggestion_enabled = true
      vim.g.copilot_filetypes = {
        ["*"] = true, -- habilita para todos os tipos de arquivo
      }
    end,
  },

  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
    },

    keys = {
      { "<leader>cca", "<CMD>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "CodeCompanion actions" },
      { "<leader>cci", "<CMD>CodeCompanion<CR>", mode = { "n", "v" }, desc = "CodeCompanion inline" },
      { "<leader>ccc", "<CMD>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "CodeCompanion chat (toggle)" },
      { "<leader>ccp", "<CMD>CodeCompanionChat Add<CR>", mode = { "v" }, desc = "CodeCompanion chat add code" },
    },

    opts = {
      display = {
        diff = {
          enabled = true, -- desabilita diff
        },
      },
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
      },
      opts = {
        language = "Portugues",
      },
    },

    config = function(_, opts)
      require("codecompanion").setup(opts)

      require("fidget").setup()
    end,
  },
}
