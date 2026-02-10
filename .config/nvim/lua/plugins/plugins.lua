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
    -- config = function()
    --   vim.cmd([[colorscheme everforest]])
    -- end,
  },

  {
    'everviolet/nvim',
    name = 'evergarden',
    priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
    opts = {
      theme = {
        variant = 'summer', -- 'winter'|'fall'|'spring'|'summer'
        accent = 'green',
      },
    },
  },

  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Palettes are the base color defines of a colorscheme.
      palettes = {
      },
      -- Spec's (specifications) are a mapping of palettes to logical groups that will be
      -- used by the groups.
      specs = {
      },
      -- Groups are the highlight group definitions. The keys of this table are the name of the highlight
      -- groups that will be overridden. The value is a table with the following values:
      --   - fg, bg, style, sp, link,
      groups = {
        all = {
          -- If `link` is defined it will be applied over any other values defined
          Conditional = { fg = "palette.red" },
          Statement = { link = "Conditional" },
          Comment = { fg = "palette.green.bright" },
        },
      },
    },
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
    'nvim-mini/mini.sessions',
    version = '*',
    config = function()
      require('mini.sessions').setup({
        autoread = true
      })
    end
  },

  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
      vim.keymap.set('n', '[p', '?^\\[[0-9]\\].*\\$<CR>:noh<CR>')
      vim.keymap.set('n', ']p', '/^\\[[0-9]\\].*\\$<CR>:noh<CR>')
    end,
  },

  {
    "dense-analysis/ale",
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      vim.g.ale_echo_cursor = 0
      vim.g.ale_python_flake8_options = '--config=$HOME/.config/flake8'
      vim.g.ale_c_clangd_options = "-I " .. vim.fn.getcwd()
      vim.g.ale_cpp_clangd_options = "-I " .. vim.fn.getcwd()
      vim.g.ale_linters = {
        java = {},
        c = {'clangcheck', 'clangd', 'clangtidy', 'cppcheck', 'cpplint'},
        haskell = {'cabal_ghc', 'hdevtools', 'hie', 'hlint', 'stack_build', 'stack_ghc'},
        tex = {'lacheck'}
      }
      vim.g.ale_linters_ignore = {
        javascript = {'tsserver'},
        typescript = {'tsserver'},
      }
    end
  },

  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({
        fzf_colors = true,
        hls = {
          header_bind = "Identifier",
          header_text = "Number",
          buf_nr = "Identifier",
          path_linenr = "Identifier",
          path_colnr = "Identifier",
          buf_flag_cur = "Number",
          buf_flag_alt = "Identifier",
          -- tab_title = "",
          tab_marker = "CursorLineNr",
          live_prompt = "FzfLuaPrompt",
          live_sym = "FzfLuaPrompt",
        },
        files = {
          -- show filename first
          formatter = "path.filename_first",
          fd_opts = [[--color=never --type f --hidden --follow --exclude .git --ignore-file ]]
            .. vim.fn.expand("$XDG_CONFIG_HOME/nvim/fd_ignore"),
        },
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
        { '<localleader>a', function() require('fzf-lua').args() end },
        { '<localleader>s', function() require('fzf-lua').live_grep() end },
        { '<localleader>d', function() require('fzf-lua').diagnostics_document() end },
        { '<localleader>h', function() require('fzf-lua').helptags() end },
        { '<localleader>u', function() require('fzf-lua').undotree() end },
        { '<localleader><localleader>', function() require('fzf-lua').resume() end },
        { '<C-x><C-f>', function() require("fzf-lua").complete_path() end, mode = 'i'},
    },
  },

  "sindrets/diffview.nvim",

  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_view_forward_search_on_start = 0
      vim.g.vimtex_compiler_latexmk = {
        out_dir = 'out'
      }
    end
  },

  {
    "SirVer/ultisnips",
    ft = "tex",
    init = function()
      vim.g.UltiSnipsExpandTrigger = "<c-j>"
      vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
    end
  },

  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      lazy_load = true,
      user_default_options = {
        names = false,
      }
    },
  },
}
