languages = {
  "bash",
  "c",
  "cpp",
  "html",
  "javascript",
  "typescript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    ft = languages,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = languages,
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        swap = {
          enable = true,
          swap_next = { [">a"] = "@parameter.inner" },
          swap_previous = { ["<a"] = "@parameter.inner" },
        },
        move = {
          enable = true,
          set_jumps = false,
          goto_next_start = { ["]m"] = "@function.outer" },
          goto_next_end = { ["]M"] = "@function.outer" },
          goto_previous_start = { ["[m"] = "@function.outer" },
          goto_previous_end = { ["[M"] = "@function.outer" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    -- enabled=false,
    ft = languages,
  },

  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
    config = function ()
      require("aerial").setup({
        -- Use on_attach to set keymaps when aerial has attached to a buffer
        -- on_attach = function(bufnr)
        --   vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        --   vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr })
        -- end,
        autojump = true,
      });
    end,
    keys = {
        -- With ! after command, cursor stays in current window
        { "<leader>a", "<cmd>AerialToggle left<CR>" },
        { "[[", "<cmd>AerialPrev<CR>" },
        { "]]", "<cmd>AerialNext<CR>" }
    },
  },
}
