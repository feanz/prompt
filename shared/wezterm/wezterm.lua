-- Adapted from https://github.com/deja666/wezterm-dotfiles at commit
-- dfce3719b07820141965d2a549dd1c7cd536d0f5. See THIRD_PARTY_NOTICES.md.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local target = wezterm.target_triple
local is_windows = target:find 'windows' ~= nil
local is_macos = target:find 'apple' ~= nil

config.default_cwd = wezterm.home_dir
config.default_workspace = 'main'
config.default_domain = 'local'

local environment = {
  TERM_PROGRAM = 'WezTerm',
  WEZTERM_EXECUTED = '1',
  WEZTERM_PREFER_WORKING_DIRECTORY = 'true',
}

if is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
elseif is_macos then
  local brew_prefix = target:find 'aarch64' and '/opt/homebrew' or '/usr/local'
  local inherited_path = os.getenv 'PATH' or '/usr/bin:/bin:/usr/sbin:/sbin'

  environment.PATH = table.concat({
    '/usr/local/share/dotnet',
    brew_prefix .. '/bin',
    brew_prefix .. '/sbin',
    wezterm.home_dir .. '/.docker/bin',
    inherited_path,
  }, ':')

  config.default_prog = { brew_prefix .. '/bin/pwsh', '-NoLogo' }
else
  config.default_prog = { 'pwsh', '-NoLogo' }
end

config.set_environment_variables = environment

config.colors = {
  foreground = '#cdd6f4',
  background = '#0b0f14',
  cursor_bg = '#7dd3fc',
  cursor_border = '#7dd3fc',
  selection_bg = '#1a1e27',
  selection_fg = '#cdd6f4',
  tab_bar = {
    background = '#0b0f14',
    active_tab = {
      bg_color = '#151b23',
      fg_color = '#7dd3fc',
    },
    inactive_tab = {
      bg_color = '#0b0f14',
      fg_color = '#6b7280',
    },
  },
}

config.window_decorations = 'RESIZE'
config.window_frame = {
  active_titlebar_bg = '#0a0d12',
  inactive_titlebar_bg = '#0f1419',
  button_bg = '#1a1e27',
  button_hover_bg = '#2a2f38',
}
config.initial_cols = 130
config.initial_rows = 30

config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
}
config.font_size = 20.0
config.line_height = 1.1
config.cell_width = 1.0
config.freetype_load_flags = 'NO_HINTING'
config.freetype_render_target = 'HorizontalLcd'

config.show_tab_index_in_tab_bar = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 32

wezterm.on('format-tab-title', function(tab)
  local cwd = tab.active_pane.current_working_dir
  local directory = '~'

  if cwd then
    local path = cwd.file_path or tostring(cwd)
    directory = path and (path:match '[^/\\]+$' or '~') or '~'
  end

  local icon = tab.is_active and '󰆍' or '󰏗'
  local background = tab.is_active and '#151b23' or '#0f1419'
  local foreground = tab.is_active and '#7dd3fc' or '#6b7280'
  local edge = '#0b0f14'

  return {
    { Background = { Color = edge } },
    { Foreground = { Color = background } },
    { Text = '' },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. icon .. ' ' .. directory .. ' ' },
    { Background = { Color = edge } },
    { Foreground = { Color = background } },
    { Text = '' },
  }
end)

config.keys = {
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = '\\', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '\\', mods = 'CTRL|ALT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CTRL|ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = '=', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'F11', mods = '', action = wezterm.action.ToggleFullScreen },
}

config.default_cursor_style = 'BlinkingBlock'
config.animation_fps = 60
config.cursor_blink_rate = 300
config.window_background_opacity = 0.9
config.text_background_opacity = 1.0
config.hide_tab_bar_if_only_one_tab = false
config.scrollback_lines = 3500
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}
config.enable_scroll_bar = false
config.selection_word_boundary = ' \t\n{}[]()"\','

wezterm.on('update-right-status', function(window, pane)
  local cwd = pane:get_current_working_dir()
  local directory = '~'

  if cwd then
    local path = cwd.file_path or tostring(cwd)
    directory = path and (path:match '[^/\\]+$' or '~') or '~'
  end

  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#94a3b8' } },
    { Text = ' 󰉋 ' },
    { Foreground = { Color = '#38bdf8' } },
    { Text = directory .. '  ' },
    { Foreground = { Color = '#64748b' } },
    { Text = '󱑍 ' },
    { Foreground = { Color = '#22d3ee' } },
    { Text = wezterm.strftime '%H:%M' .. ' ' },
  })
end)

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

config.adjust_window_size_when_changing_font_size = true
if not is_windows and not is_macos then
  config.enable_wayland = false
end

return config
