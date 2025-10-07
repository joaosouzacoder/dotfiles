return {
  {
    "github/copilot.vim",
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
