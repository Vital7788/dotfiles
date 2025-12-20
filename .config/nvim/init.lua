-- source vimrc
vim.cmd('source ~/.vim/vimrc')

if vim.g.vscode then
  vim.cmd.source(vim.fn.stdpath("config") .. "/vscode.lua")
  return
end

vim.opt.mousemodel="extend"
vim.opt.smoothscroll = true
vim.opt.signcolumn = "no"
vim.opt.inccommand = "split"

-- plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
  },
})

-- diagnostics
vim.diagnostic.config({
  severity_sort = true,
  float = { border = 'rounded', source = true },
  virtual_text = { source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.WARNING },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  },
})

-- set max width of lsp/diagnostic floating windows to 80
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width= opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)

vim.cmd([[colorscheme dayfox]])
