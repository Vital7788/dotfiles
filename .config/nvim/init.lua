---- Vimrc
vim.cmd('source ~/.vim/vimrc')

if vim.g.vscode then
  vim.cmd.source(vim.fn.stdpath("config") .. "/vscode.lua")
  return
end

vim.opt.mousemodel="extend"
vim.opt.smoothscroll = true
vim.opt.signcolumn = "yes"
vim.opt.statuscolumn = "%l%s"
vim.opt.inccommand = "split"

---- Plugins
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

---- Diagnostics
local virtual_lines_format = function(diagnostic)
  return string.format("%s: %s [%s]", diagnostic.source, diagnostic.message, diagnostic.code)
end

vim.diagnostic.config({
  severity_sort = true,
  float = { border = 'rounded', source = true },
  virtual_text = { current_line = true },
  virtual_lines = false,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  },
})

-- set max width of lsp/diagnostic floating windows to 120
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width= opts.max_width or 120
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>d', function ()
    vim.diagnostic.config {
        virtual_lines = not vim.diagnostic.config().virtual_lines and { current_line = true, format = virtual_lines_format } or false,
        virtual_text = not vim.diagnostic.config().virtual_text and { current_line = true } or false,
     }
end)

---- LSP
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- nowait is necessary to avoid waiting for the default lsp mappings, see :map gr
    vim.keymap.set('n', 'gr', require('fzf-lua').lsp_references, { nowait = true, buffer = event.buf, desc = 'LSP: [G]oto [R]eferences'})
    map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
    map('gD', require('fzf-lua').lsp_declarations, '[G]oto [D]eclaration')
    map('gI', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')

    map('crn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('crr', vim.lsp.buf.code_action, 'Code Action')
    map('cra', vim.lsp.buf.code_action, 'Code [A]ction')

    map('K', function()
      vim.lsp.buf.hover { border = "rounded", max_width = 120 }
    end, 'Hover Documentation')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      -- quicker CursorHold events
      vim.opt.updatetime=300

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client:supports_method('textDocument/completion') then
      -- Enable completion side effects, such as auto-imports
      vim.lsp.completion.enable(true, client.id, event.buf, {autotrigger = false})
    end
  end,
})

---- Colorscheme
vim.cmd([[colorscheme dayfox]])

---- Modeline
-- vim:fdm=expr
-- vim:fde=getline(v\:lnum)=~'^---'?'>'.(matchend(getline(v\:lnum),'---*')-3)\:'='
