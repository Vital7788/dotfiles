""" Source vimrc
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vim/vimrc

""" Plugins
call plug#begin('~/.vim/nvim_plug')
function! UpdateRemotePlugins(...)
    " Needed to refresh runtime files
    let &rtp=&rtp
    UpdateRemotePlugins
endfunction

Plug 'romainl/vim-cool'
Plug 'romainl/vim-qf'
Plug 'tpope/vim-abolish'
Plug 'mbbill/undotree'
Plug 'ggandor/leap.nvim'

Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'
"Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh' }
Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }

" Need to run install script in the folder where the plugin is installed
Plug 'nixprime/cpsm'
Plug 'romgrk/fzy-lua-native'

Plug 'lervag/vimtex'
Plug 'SirVer/ultisnips'
Plug 'KeitaNakamura/tex-conceal.vim'

"Plug 'arcticicestudio/nord-vim'
Plug 'rakr/vim-one'
Plug 'joshdick/onedark.vim'
Plug 'romainl/apprentice'
Plug 'sainnhe/everforest'
"Plug 'shaunsingh/nord.nvim'
"Plug 'andersevenrud/nordic.nvim'

"Plug 'hrsh7th/cmp-nvim-lsp'
"Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
"Plug 'hrsh7th/cmp-buffer'
"Plug 'hrsh7th/cmp-path'
"Plug 'hrsh7th/nvim-cmp'

call plug#end()

let g:tex_flavor='latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode=0
let g:vimtex_view_forward_search_on_start=0
"set conceallevel=1
"let g:tex_conceal='abdmg'

let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

let g:ale_disable_lsp = 1
let g:ale_use_neovim_diagnostics_api = 1

lua << EOF
require('leap').set_default_keymaps()
--require('leap').setup {
--    case_insensitive = false,
--    safe_labels = {}
--}
EOF

""" Colorscheme
set termguicolors
set background=light
let g:everforest_background='medium'
let g:everforest_better_performance=1
colorscheme everforest

""" LSP
lua << EOF

--local cmp = require('cmp')
--
--cmp.setup({
--  mapping = cmp.mapping.preset.insert({
--    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
--    ['<C-f>'] = cmp.mapping.scroll_docs(4),
--    ['<C-Space>'] = cmp.mapping.complete(),
--    ['<C-e>'] = cmp.mapping.abort(),
--    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--  }),
--  enabled = function()
--    -- disable completion in comments
--    local context = require 'cmp.config.context'
--    -- keep command mode completion enabled when cursor is in a comment
--    if vim.api.nvim_get_mode().mode == 'c' then
--      return true
--    else
--      return not context.in_treesitter_capture("comment")
--        and not context.in_syntax_group("Comment")
--    end
--  end,
--  sources = cmp.config.sources({
--    { name = 'nvim_lsp' },
--  }, {
--    { name = 'nvim_lsp_signature_help' },
--  }, {
--    { name = 'buffer' },
--  }, {
--    { name = 'path' },
--  })
--})
--
---- Set up lspconfig.
---- Capabilities have to be set for each enabled lsp server
--local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason").setup()

-- uncomment to enable logging
--vim.lsp.set_log_level("debug")
-- execute following command to view logfile
-- :lua vim.cmd('e'..vim.lsp.get_log_path())

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
--local servers = { 'clangd', 'texlab', 'jdtls', 'pyright', 'pylsp', 'ltex' }
local servers = { 'clangd', 'texlab', 'jdtls', 'pyright', 'pylsp' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    --capabilities = capabilities,
    settings = {
        pylsp = {
            configurationSources = {"flake8"},
            plugins = {
                pycodestyle = {enabled = false},
                --flake8 = {enabled = true},
                jedi_completion = {fuzzy = true},
                rope_autoimport = {enabled = true}
            }
        },
        python = {
            analysis = {
                autoImportCompletions = true
            }
        }
    },
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
end

vim.diagnostic.config({
  virtual_text = {
    --source = "always",
    format = fmt,
  },
  float = {
    source = "always",
    format = fmt,
  },
})
EOF

""" Treesitter

lua << EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "cpp", "python", "javascript", "bash" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { "javascript" },

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
      enable = true
  }
}
EOF


""" Mappings
nnoremap <F5> :UndotreeToggle<CR>

"" vim:fdm=expr:fdl=0
"" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
