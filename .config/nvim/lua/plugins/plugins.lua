return {
  "romainl/vim-cool",
  "romainl/vim-qf",
  "tpope/vim-abolish",
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
    enabled = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- Used by the code blocks
    },

    config = function ()
      require("markview").setup();
    end
  }
}
