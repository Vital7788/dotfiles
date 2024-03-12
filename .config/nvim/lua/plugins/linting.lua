return {
  {
    "dense-analysis/ale",
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
      --vim.g.ale_disable_lsp = 1
      --vim.g.ale_use_neovim_diagnostics_api = 1
      vim.g.ale_echo_msg_format = '%linter%: %s'
    end
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
  }
}
