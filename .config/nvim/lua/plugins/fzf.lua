return {
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- calling `setup` is optional for customization
      require('fzf-lua').setup({})
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
}
