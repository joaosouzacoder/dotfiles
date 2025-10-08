return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = true, -- ou false se quiser desativar totalmente
        },
      },
      cmdline = {
        view = "cmdline",
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)

      -- 🛠️ Patch para corrigir erros de progresso com Roslyn
      vim.lsp.handlers["$/progress"] = function(_, result, ctx)
        local ok, noice = pcall(require, "noice.lsp.progress")
        if ok and result and result.value and result.value.kind then
          pcall(noice.progress_handler, _, result, ctx)
        end
      end
    end,
  },
}
