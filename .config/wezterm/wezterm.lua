local wezterm = require('wezterm')
local utils = require('utils')

local config = wezterm.config_builder()

local scheme = 'Night Owl (Gogh)'
local scheme_def = wezterm.color.get_builtin_schemes()[scheme]
local primary_font = 'Maple Mono Normal NF CN'
local secondary_font = 'Liga SFMono Nerd Font'
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- Window settings
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.scrollback_lines = 100000
config.initial_rows = 32
config.initial_cols = 133
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
config.colors = {
  visual_bell = '#202020',
}
config.window_frame = {
    -- Fonts for the tab bar
    font = wezterm.font {
        family = primary_font,
        weight = 'Bold'
    },
    font_size = 14
}
config.window_padding = {
    left = "1cell",
    right = "1cell",
    top = "2cell",
    bottom = "0.5cell"
}

-- Color
config.color_scheme = scheme
-- Background transparency
config.window_background_opacity = 0.85
config.macos_window_background_blur = 80

-- Cursor settings
config.max_fps = 144
config.animation_fps = 144
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700

-- Font settings
-- Font for the text
config.font = wezterm.font_with_fallback({{
    family = primary_font,
    weight = 'Medium'
}, {
    family = secondary_font,
    weight = 'Regular'
}})
config.line_height = 1.1
config.font_size = 16

-- Tab bar settings
config.tab_bar_at_bottom = true
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local cwd_uri = pane.current_working_dir
    local directoryName = 'Unknown'
    local process = utils.get_process(tab)

    if cwd_uri then
        -- Convert the URI to a string, remove the hostname, and decode %20s:
        local cwd_path = cwd_uri.file_path
        directoryName = utils.getDirectoryName(cwd_path)
    end

    local title = string.format(' %s: %s (%s) ', (tab.tab_index + 1), directoryName, process)

    return {{
        Text = title
    }}
end)

-- Status bar
config.status_update_interval = 500
wezterm.on('update-right-status', function(window, pane)
    local hostname = wezterm.hostname()

    window:set_right_status(wezterm.format({{
        Foreground = {
            Color = scheme_def.foreground
        }
    }, {
        Background = {
            Color = 'none'
        }
    }, {
        Text = wezterm.nerdfonts.oct_person_fill .. " " .. hostname
    }, {
        Text = "   "
    }}))
end)

-- Key bindings
config.keys = { -- Option-left for backward-word
{
    key = "LeftArrow",
    mods = "OPT",
    action = wezterm.action {
        SendString = "\x1bb"
    }
}, -- Option-right for forward-word
{
    key = "RightArrow",
    mods = "OPT",
    action = wezterm.action {
        SendString = "\x1bf"
    }
}, { -- Fix insert key for macOS
    key = "\u{f746}",
    mods = "",
    action = wezterm.action {
        SendString = "\x1b[2~"
    }
}, { -- Fix shift+insert key for macOS
    key = "\u{f746}",
    mods = "SHIFT",
    action = wezterm.action.PasteFrom 'Clipboard'
} -- End of key bindings
}

return config
