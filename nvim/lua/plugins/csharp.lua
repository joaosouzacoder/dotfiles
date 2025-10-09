return {
  "seblyng/roslyn.nvim",
  ---@module 'roslyn.config'
  dotnet_cmd = "/Users/johnsouza/.asdf/installs/dotnet-core/9.0.0/dotnet",
  --opcional: habilitar LSP logs pra debug
  log_level = "debug",
  opts = {
    on_attach = function()
      -- Caminho do dotnet via asdf
      local dotnet_path = "/Users/johnsouza/.asdf/installs/dotnet-core/9.0.0/dotnet"
      if dotnet_path ~= "" then
        vim.env.DOTNET_ROOT = dotnet_path
        vim.env.PATH = dotnet_path .. "/bin:" .. vim.env.PATH
      end
    end,
  },
}
