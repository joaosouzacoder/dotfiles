if vim.env.VSCODE then
  vim.g.vscode = true
end

if vim.loader then
  vim.loader.enable()
end

_G.dd = function(...)
  require("snacks.debug").inspect(...)
end
_G.bt = function(...)
  require("snacks.debug").backtrace()
end
_G.p = function(...)
  require("snacks.debug").profile(...)
end
vim._print = function(_, ...)
  dd(...)
end

if vim.env.PROF then
  require("snacks.profiler").startup({
    startup = {
      -- event = "UIEnter",
      -- event = "VeryLazy",
    },
  })
end

pcall(require, "config.env")

require("config.lazy").load({
  -- debug = false,
  profiling = {
    loader = false,
    require = true,
  },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("util").version()
  end,
})
