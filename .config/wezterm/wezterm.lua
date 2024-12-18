local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- config.automatically_reload_config = false

config.audible_bell = "Disabled"

config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font {
    family = 'FiraCode Nerd Font',
    harfbuzz_features = { "ss03", "ss05" },
}
config.font_size = 11.5
-- config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

--config.color_scheme = 'nord'
config.color_scheme = 'Everforest Light (Gogh)'
config.window_frame = {
  font = wezterm.font { family = 'Roboto', weight = 'Bold' },

  font_size = 11.0,

  active_titlebar_bg = '#efebd4',
  inactive_titlebar_bg = '#efebd4',
}

config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = '#fdf6e3',
      fg_color = '#5c6a72',
    },
    inactive_tab = {
      bg_color = '#efebd4',
      fg_color = '#829181',
    },
    inactive_tab_hover = {
      bg_color = '#f4f0d9',
      fg_color = '#5c6a72',
    },
    new_tab = {
      bg_color = '#efebd4',
      fg_color = '#829181',
    },
    new_tab_hover = {
      bg_color = '#f4f0d9',
      fg_color = '#5c6a72',
    },
    inactive_tab_edge = '#939f91',
  },
  cursor_fg = '#fdf6e3',
  cursor_bg = '#5c6a72',
  cursor_border = '#5c6a72',
}

config.keys = {
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(wezterm.action.CopyTo('Clipboard'), pane)
        window:perform_action(wezterm.action.ClearSelection, pane)
      else
        window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
      end
    end),
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        window:perform_action(wezterm.action.SendKey{ key='v', mods='CTRL' }, pane)
      else
        window:perform_action(wezterm.action{ PasteFrom = 'Clipboard' }, pane)
      end
    end),
  },
  { key = 'v', mods = 'SHIFT|CTRL', action = wezterm.action_callback(function(window, pane)
    window:perform_action(wezterm.action.SendKey{ key='v', mods='CTRL' }, pane) end),
  },
  {
    key = 'o',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.QuickSelectArgs {
      label = 'open url',
      patterns = {
        'https?://\\S+',
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. url)
        wezterm.open_with(url)
      end),
    },
  },
  { key = 'PageUp', action = wezterm.action.ScrollToPrompt(-1) },
  { key = 'PageDown', action = wezterm.action.ScrollToPrompt(1) },
}

config.mouse_bindings = {
  {
    event = { Down = { streak = 4, button = 'Left' } },
    action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
  },
}

return config
