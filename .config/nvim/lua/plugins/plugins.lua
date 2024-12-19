return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    init = function()
      vim.opt.termguicolors = true
      vim.opt.background = 'light'
      vim.g.everforest_background = 'medium'
      vim.g.everforest_better_performance = 1
    end,
    config = function()
      vim.cmd([[colorscheme everforest]])
    end,
  },
  "romainl/vim-cool",
  {
    "romainl/vim-qf",
    init = function()
      vim.g.qf_shorten_path = 3
    end,
  },
  "tpope/vim-abolish",
  "tpope/vim-sleuth",
  {
    "mbbill/undotree",
    keys = {
        { "<F5>", "<cmd>UndotreeToggle<CR>" }
    }
  },
  {
    "dense-analysis/ale",
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
      vim.g.ale_use_neovim_diagnostics_api = 1
      -- vim.g.ale_disable_lsp = 0
      vim.g.ale_echo_cursor = 0
    end
  },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- calling `setup` is optional for customization
      require('fzf-lua').setup({
        keymap = {
            fzf = {
                ["ctrl-q"] = "select-all+accept",
            },
        },
      })
    end,
    keys = {
        { '<localleader>f', function() require('fzf-lua').files() end },
        { '<localleader>b', function() require('fzf-lua').buffers() end },
        { '<localleader>s', function() require('fzf-lua').live_grep() end },
        { '<localleader>d', function() require('fzf-lua').diagnostics_document() end },
        { '<localleader>h', function() require('fzf-lua').helptags() end },
        { '<localleader><localleader>', function() require('fzf-lua').resume() end },
        { '<C-x><C-f>', function() require("fzf-lua").complete_path() end, mode = 'i'},
    },
  },
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_view_forward_search_on_start = 0
    end
  },
  {
    "KeitaNakamura/tex-conceal.vim",
    enabled = false,
    init = function()
      vim.opt.conceallevel = 1
      vim.g.tex_conceal = 'abdmg'
    end
  },
  {
    "SirVer/ultisnips",
    init = function()
      vim.g.UltiSnipsExpandTrigger = "<c-j>"
      vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
    end
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons", -- Used by the code blocks
    },

    -- opts = {
    -- }
  },
  {
      "NvChad/nvim-colorizer.lua",
      event = "BufReadPre",
      ft = "css",
      opts = {
        -- css = true,
        colors = false,
      },
  },
}
