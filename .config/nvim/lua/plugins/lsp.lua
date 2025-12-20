return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    ft = {"tex", "python", "c", "cpp", "lua", "javascript", "typescript", "javascriptreact", "typescriptreact"},
    -- cond = (function() return not vim.g.vscode end),
    cmd = { "Mason" },
    config = function()
      -- setup keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
          map('gd', vim.lsp.buf.definition, '[G]oto [D]eclaration')
          -- map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
          -- map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gD', require('fzf-lua').lsp_declarations, '[G]oto [D]eclaration')
          map('gI', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')
          -- map('<localleader>D', require('fzf-lua').lsp_type_definitions, 'Type [D]efinition')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Fuzzy find all the symbols in your current document.
          map('<localleader>ds', require('fzf-lua').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace
          map('<localleader>ws', require('fzf-lua').lsp_live_workspace_symbols, '[W]orkspace [S]ymbols')

          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          map('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, 'List workspace folders')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            -- quicker CursorHold events
            vim.opt.updatetime=300

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          if client:supports_method('textDocument/completion') then
            -- Enable completion side effects, such as auto-imports
            vim.lsp.completion.enable(true, client.id, event.buf, {autotrigger = false})
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP Specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      --capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local mason_servers = {
        pylsp = {
          settings = {
            pylsp = {
              configurationSources = {"flake8"},
              plugins = {
                pycodestyle = {enabled = false},
                --flake8 = {enabled = true},
                jedi_completion = {fuzzy = true},
                rope_autoimport = {enabled = true}
              }
            },
            python = {
              analysis = {
                autoImportCompletions = true
              }
            }
          }
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      local local_servers = {
        texlab = {},
        -- jdtls = {},
        pyright = {},
        clangd = {},
        -- ts_ls = {},
      }

      require('mason').setup()

      local register = function(server_name, server)
        require('lspconfig')[server_name].setup {
          cmd = server.cmd,
          settings = server.settings,
          filetypes = server.filetypes,
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for tsserver)
          capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}),
        }
      end

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = mason_servers[server_name] or {}
            register(server_name, server)
          end,
        },
      }

      for server_name, server in pairs(local_servers) do
        register(server_name, server)
      end
    end,
  },
}
