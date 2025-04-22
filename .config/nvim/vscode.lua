
  local vscode = require('vscode')
  local keymap = vim.api.nvim_set_keymap
  local function action(cmd)
    return string.format("<cmd>lua require('vscode').action('%s')<CR>", cmd)
  end

  -- list of potentially useful VS Code commands
  -- 'references-view.findReferences' -- language references
  -- 'workbench.actions.view.problems' -- language diagnostics
  -- 'editor.action.goToReferences'
  -- 'editor.action.rename'
  -- 'editor.action.formatDocument'
  -- 'editor.action.refactor' -- language code actions
  -- --
  -- 'workbench.action.findInFiles' -- use ripgrep to search files
  -- 'workbench.action.toggleSidebarVisibility'
  -- 'workbench.action.toggleAuxiliaryBar' -- toggle docview (help page)
  -- 'workbench.action.togglePanel'
  -- 'workbench.action.showCommands' -- find commands
  -- 'workbench.action.quickOpen' -- find files
  -- 'workbench.action.terminal.toggleTerminal' -- terminal window
  -- --
  -- 'editor.action.formatSelection'
  -- 'editor.action.refactor'
  -- 'workbench.action.showCommands'

  vim.keymap.set('n', '<Leader>rl', action('workbench.action.reloadWindow'))
  vim.keymap.set('n', '<Leader>fm', action('workbench.action.formatDocument'))
  vim.keymap.set('n', ',f', action('workbench.action.quickOpen'))
  vim.keymap.set('n', ',s', action('workbench.action.findInFiles'))
  vim.keymap.set('n', 'gr', action('editor.action.goToReferences'))
  vim.keymap.set('n', '<Leader>rn', action('editor.action.rename'))
