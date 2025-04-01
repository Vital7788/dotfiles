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
    source = true,
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

if vim.g.vscode then
  local vscode = require('vscode')
  local keymap = vim.api.nvim_set_keymap
  local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
  end

  local function v_notify(cmd)
    return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<CR>", cmd)
  end

  local function action(cmd)
    return string.format("<cmd>lua require('vscode').action('%s')<CR>", cmd)
  end

  -- keymap('n', '<Leader>xr', notify 'references-view.findReferences', { silent = true }) -- language references
  -- keymap('n', '<Leader>xd', notify 'workbench.actions.view.problems', { silent = true }) -- language diagnostics
  -- keymap('n', 'gr', notify 'editor.action.goToReferences', { silent = true })
  -- keymap('n', '<Leader>rn', notify 'editor.action.rename', { silent = true })
  -- keymap('n', '<Leader>fm', notify 'editor.action.formatDocument', { silent = true })
  -- keymap('n', '<Leader>ca', notify 'editor.action.refactor', { silent = true }) -- language code actions
  --
  -- keymap('n', '<Leader>rg', notify 'workbench.action.findInFiles', { silent = true }) -- use ripgrep to search files
  -- keymap('n', '<Leader>ts', notify 'workbench.action.toggleSidebarVisibility', { silent = true })
  -- keymap('n', '<Leader>th', notify 'workbench.action.toggleAuxiliaryBar', { silent = true }) -- toggle docview (help page)
  -- keymap('n', '<Leader>tp', notify 'workbench.action.togglePanel', { silent = true })
  -- keymap('n', '<Leader>fc', notify 'workbench.action.showCommands', { silent = true }) -- find commands
  -- keymap('n', '<Leader>ff', notify 'workbench.action.quickOpen', { silent = true }) -- find files
  -- keymap('n', '<Leader>tw', notify 'workbench.action.terminal.toggleTerminal', { silent = true }) -- terminal window
  --
  -- keymap('v', '<Leader>fm', v_notify 'editor.action.formatSelection', { silent = true })
  -- keymap('v', '<Leader>ca', v_notify 'editor.action.refactor', { silent = true })
  -- keymap('v', '<Leader>fc', v_notify 'workbench.action.showCommands', { silent = true })
  vim.keymap.set('n', ',f', action('workbench.action.quickOpen'))
end

