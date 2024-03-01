return {
  "romainl/vim-cool",
  "romainl/vim-qf",
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
}
