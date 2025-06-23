local wezterm = require('wezterm')

local function getDirectoryName(path)
    if not path then
        return 'Unknown'
    end
    -- Remove any trailing slashes from the path
    path = path:gsub("/+$", "")
    -- Extract the last part of the path (the directory name)
    local directoryName = path:match("([^/]+)$")
    return directoryName or 'Unknown'
end

local process_icons = { -- for get_process function
    ['docker'] = wezterm.nerdfonts.linux_docker,
    ['docker-compose'] = wezterm.nerdfonts.linux_docker,
    ['psql'] = wezterm.nerdfonts.dev_postgresql,
    ['kuberlr'] = wezterm.nerdfonts.linux_docker,
    ['kubectl'] = wezterm.nerdfonts.linux_docker,
    ['stern'] = wezterm.nerdfonts.linux_docker,
    ['nvim'] = wezterm.nerdfonts.custom_vim,
    ['make'] = wezterm.nerdfonts.seti_makefile,
    ['vim'] = wezterm.nerdfonts.dev_vim,
    ['go'] = wezterm.nerdfonts.seti_go,
    ['zsh'] = wezterm.nerdfonts.dev_terminal,
    ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
    ['btm'] = wezterm.nerdfonts.mdi_chart_donut_variant,
    ['htop'] = wezterm.nerdfonts.mdi_chart_donut_variant,
    ['cargo'] = wezterm.nerdfonts.dev_rust,
    ['sudo'] = wezterm.nerdfonts.fa_hashtag,
    ['lazydocker'] = wezterm.nerdfonts.linux_docker,
    ['git'] = wezterm.nerdfonts.dev_git,
    ['lua'] = wezterm.nerdfonts.seti_lua,
    ['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
    ['curl'] = wezterm.nerdfonts.mdi_flattr,
    ['gh'] = wezterm.nerdfonts.dev_github_badge,
    ['ruby'] = wezterm.nerdfonts.cod_ruby,
    ['pwsh'] = wezterm.nerdfonts.seti_powershell,
    ['node'] = wezterm.nerdfonts.dev_nodejs_small,
    ['dotnet'] = wezterm.nerdfonts.md_language_csharp
}

local function get_process(tab)
    local process_name = tab.active_pane.foreground_process_name:match("([^/\\]+)%.exe$") or
                             tab.active_pane.foreground_process_name:match("([^/\\]+)$")

    -- local icon = process_icons[process_name] or string.format('[%s]', process_name)
    local icon = process_icons[process_name] or wezterm.nerdfonts.seti_checkbox_unchecked

    return string.format("%s %s", icon, process_name)
end

return {
    getDirectoryName = getDirectoryName,
    get_process = get_process
}