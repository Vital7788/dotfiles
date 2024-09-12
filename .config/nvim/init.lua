-- source vimrc
vim.cmd('source ~/.vim/vimrc')

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
  underline = true,
  virtual_text = true,
  severity_sort = true,
  float = {
    source = "always",
  },
})

vim.fn.sign_define("DiagnosticSignError", {text="", texthl="DiagnosticSignError", numhl="DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text="", texthl="DiagnosticSignWarn", numhl="DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text="", texthl="DiagnosticSignInfo", numhl="DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text="", texthl="DiagnosticSignHint", numhl="DiagnosticSignHint"})

-- set max width of lsp/diagnostic floating windows to 80
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width= opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
