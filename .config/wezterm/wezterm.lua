local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.audible_bell = "Disabled"

config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 11
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

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
      selection_text = window:get_selection_text_for_pane(pane)
      is_selection_active = string.len(selection_text) ~= 0
      if is_selection_active then
        window:perform_action(wezterm.action.CopyTo('Clipboard'), pane)
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
}

config.mouse_bindings = {
    -- Disable the default click behavior
    {
      event = { Up = { streak = 1, button = "Left"} },
      mods = "NONE",
      action = wezterm.action.DisableDefaultAssignment,
    },
    -- Shift-click will open the link under the mouse cursor
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "SHIFT",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
    -- Disable the Shift-click down event to stop programs from seeing it when a URL is clicked
    {
        event = { Down = { streak = 1, button = "Left" } },
        mods = "SHIFT",
        action = wezterm.action.Nop,
    },
}

return config
