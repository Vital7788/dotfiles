return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    init = function()
      vim.opt.termguicolors = true
      vim.opt.background = 'light'
      vim.g.everforest_background = 'medium'
    end,
    config = function()
      vim.cmd([[colorscheme everforest]])
    end,
  }
}
