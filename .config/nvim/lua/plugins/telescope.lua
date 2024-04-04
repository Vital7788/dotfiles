return {
  {
    'nvim-telescope/telescope.nvim',
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
    config = function(_, opts)
      pcall(require('telescope').load_extension, 'fzf')

      require('telescope').setup(opts)
    end,
    keys = {
      { '<localleader>f', function() require('telescope.builtin').find_files() end },
      { '<localleader>/', function() require('telescope.builtin').live_grep() end },
      { '<localleader>b', function() require('telescope.builtin').buffers() end },
      { '<localleader>h', function() require('telescope.builtin').help_tags() end },
      { '<localleader>d', function() require('telescope.builtin').diagnostics() end },
      { '<localleader><localleader>', function() require('telescope.builtin').resume() end },
    },
    opts = function()
      return {
        defaults = vim.tbl_extend(
          "force",
          require('telescope.themes').get_dropdown(),
          {
            file_ignore_patterns = {
              -- Documents
              '%.docx$', '%.odp$', '%.ods$', '%.odt$', '%.pdf$', '%.ppt$', '%.pptx$', '%.xls$', '%.xlsx$',

              -- Images
              '%.gif$', '%.ico$', '%.jpeg$', '%.jpg$', '%.png$',

              -- Audio
              '%.flac$', '%.mp3$', '%.opus$', '%.wav$',

              -- Video
              '%.mp4$', '%.webm$', '%.mkv$',
            },
            path_display = {
              truncate = 1,
            },
            dynamic_preview_title = true,
          }
        ),
        pickers = {
          find_files = {
            follow = true,
          },
          lsp_references = {
            initial_mode = "normal",
          },
          lsp_definitions = {
            initial_mode = "normal",
          },
          lsp_implementations = {
            initial_mode = "normal",
          },
          lsp_type_definitions = {
            initial_mode = "normal",
          },
        },
      }
    end,
  },
}
