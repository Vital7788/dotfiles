return {
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
    "sheerun/vim-polyglot",
    enabled = false,
  },
  {
    "mbbill/undotree",
    keys = {
        { "<F5>", "<cmd>UndotreeToggle<CR>" }
    }
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
  }
}
