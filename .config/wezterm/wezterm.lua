local wezterm = require('wezterm')
local utils = require('utils')
local config = wezterm.config_builder()
local act = wezterm.action

local scheme = 'Night Owl (Gogh)'
local primary_font = 'Maple Mono Normal NF CN'
local secondary_font = 'Liga SFMono Nerd Font'

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

-- Window settings
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.scrollback_lines = 100000
config.initial_rows = 32
config.initial_cols = 133
config.audible_bell = "Disabled"
config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = 'CursorColor'
}
config.colors = {
    visual_bell = '#202020'
}
config.window_frame = {
    -- Fonts for the tab bar
    font = wezterm.font {
        family = secondary_font,
        weight = 'Regular'
    },
    font_size = 14
}
config.window_padding = {
    left = "1.5cell",
    right = "1.5cell",
    top = "2cell",
    bottom = "1cell"
}
-- Tab bar settings
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

    local title = string.format(' [%s] %s (%s) ', (tab.tab_index + 1), directoryName, process)

    return {{
        Text = title
    }}
end)
-- Right status information
function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end
wezterm.on('update-right-status', function(window, pane)
    local date = wezterm.strftime('%H:%M ')
    local process_name = basename(pane:get_foreground_process_name())

    window:set_right_status(
        wezterm.nerdfonts.fa_terminal .. ' ' .. process_name .. ' ' .. wezterm.nerdfonts.fa_clock_o .. ' ' .. date ..
            ' ')
end)

-- Color
config.color_scheme = scheme
-- Background transparency
config.window_background_opacity = 0.9
config.macos_window_background_blur = 80
-- Search colors
config.colors.copy_mode_active_highlight_fg = {
    AnsiColor = 'Black'
}
config.colors.copy_mode_active_highlight_bg = {
    AnsiColor = 'Lime'
}
config.colors.copy_mode_inactive_highlight_fg = {
    AnsiColor = 'Black'
}
config.colors.copy_mode_inactive_highlight_bg = {
    AnsiColor = 'Green'
}

-- Cursor settings
config.max_fps = 60
config.animation_fps = 60
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700

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
}, { -- Fix cmd+left key for macOS
    key = "LeftArrow",
    mods = "CMD",
    action = wezterm.action {
        SendString = "\x1bOH"
    }
}, { -- Fix cmd+right key for macOS
    key = "RightArrow",
    mods = "CMD",
    action = wezterm.action {
        SendString = "\x1bOF"
    }
},{
    key = "f",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
        -- window:perform_action(act.Search 'CurrentSelectionOrEmptyString', pane)
        window:perform_action(act.Search {
            CaseInSensitiveString = ""
        }, pane)
        window:perform_action(act.Multiple {act.CopyMode 'ClearPattern', act.CopyMode 'ClearSelectionMode',
                                            act.CopyMode 'MoveToScrollbackBottom'}, pane)
    end)
}, {
    key = "Home",
    mods = "",
    action = wezterm.action {
        SendString = "\x1bOH"
    }
}, {
    key = "End",
    mods = "",
    action = wezterm.action {
        SendString = "\x1bOF"
    }
}}

-- Configure search mode
local copy_mode = nil
if wezterm.gui then
    search_mode = wezterm.gui.default_key_tables().search_mode
    table.insert(search_mode, {
        key = "Enter",
        mods = "",
        action = act.CopyMode 'NextMatch'
    })
    table.insert(search_mode, {
        key = "Enter",
        mods = "SHIFT",
        action = act.CopyMode 'PriorMatch'
    })
    table.insert(search_mode, {
        key = "c",
        mods = "CTRL",
        action = act.Multiple {"ScrollToBottom", {
            CopyMode = "Close"
        }}
    })
end
-- Update key tables with new keys
config.key_tables = {
    search_mode = search_mode
}

return config
-- EOF
