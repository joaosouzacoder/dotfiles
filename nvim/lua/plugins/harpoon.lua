return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2", -- usa a nova versão
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
      local harpoon = require("harpoon")

      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            return vim.loop.cwd() -- salva por projeto
          end,
        },
      })

      -- atalhos principais
      local wk = require("which-key")

      wk.add({
        { "<leader>h", group = "Harpoon" },
        {
          "<leader>ha",
          function()
            harpoon:list():add()
          end,
          desc = "Add file",
        },
        {
          "<leader>hl",
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "List files",
        },
        {
          "<leader>hn",
          function()
            harpoon:list():next()
          end,
          desc = "Next file",
        },
        {
          "<leader>hp",
          function()
            harpoon:list():prev()
          end,
          desc = "Previous file",
        },
      })

      -- atalhos diretos para slots
      vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
      end)
      vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
      end)
      vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
      end)
      vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
      end)
    end,
  },
}
