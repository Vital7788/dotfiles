return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        enabled = vim.fn.executable("cmake") == 1,
      },
      { 'nvim-tree/nvim-web-devicons' }
    },
    config = function()
      pcall(require('telescope').load_extension, 'fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<localleader>f', builtin.find_files, {})
      vim.keymap.set('n', '<localleader>/', builtin.live_grep, {})
      vim.keymap.set('n', '<localleader>b', builtin.buffers, {})
      vim.keymap.set('n', '<localleader>h', builtin.help_tags, {})
    end,
  },
}
