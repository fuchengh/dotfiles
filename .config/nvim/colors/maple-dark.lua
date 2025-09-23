-- lua/colors/maple-dark.lua
-- Maple Dark (Neovim) — ported from vscode json
-- Author: subframe7536 (ported by me)

local M = {}

local p = {
  -- base & UI
  name = "maple-dark",
  bg = "#1e1e1f",
  fg = "#cbd5e1",

  -- terminal 16
  t_black = "#333333",
  t_red = "#edabab",
  t_green = "#a4dfae",
  t_yellow = "#eecfa0",
  t_blue = "#8fc7ff",
  t_magenta = "#d2ccff",
  t_cyan = "#a1e8e5",
  t_white = "#f3f2f2",
  t_bblack = "#666666",
  t_bred = "#ffc4c4",
  t_bgreen = "#bdf8c7",
  t_byellow = "#ffe8b9",
  t_bblue = "#a8e0ff",
  t_bmagenta = "#ebe5ff",
  t_bcyan = "#bafffe",
  t_bwhite = "#ffffff",

  -- VS Code UI colors mapped
  focusBorder = "#64748b",
  selection_bg = "#475569",    -- editor.selectionBackground
  selection_bg_inactive = "#475569b3",
  selection_bg_soft = "#47556966",
  selection_border = "#44444b",
  snippet_tabstop_bg = "#47556999",
  hover_bg = "#4755694d",
  linehl_bg = "#47556940",
  linehl_border = "#4755694d",
  range_bg = "#1e293be6",
  range_border = "#334155e6",
  tabs_bg = "#171718",
  tabs_border = "#232a39",
  peek_bg = "#232a3980",
  peek_res_bg = "#212122",
  peek_title_bg = "#232a39",
  widget_border = "#44444b",
  widget_bg = "#232a39",
  widget_shadow = "#171718cc",
  find_bg = "#8dbe744d",
  find_border = "#64748b",
  find_hl_bg = "#8dbe7433",
  find_range_bg = "#1e293b66",
  find_range_border = "#334155cc",
  link = "#8dbe74",
  link_active = "#a1d288",
  cursor = "#8d9db4",
  multicursor = "#8d9db4cc",
  inlay_fg = "#f5e7d6",
  inlay_bg = "#3b5b7d",
  linenr_fg = "#999999b3",
  linenr_fg_active = "#fafafa",
  indent_active = "#cbd5e1cc",
  indent = "#cbd5e140",
  gutter_add = "#a4dfaee6",
  gutter_add2 = "#a4dfaeb3",
  gutter_del = "#edababe6",
  gutter_del2 = "#edababb3",
  gutter_mod = "#8fc7ffe6",
  gutter_mod2 = "#8fc7ffb3",
  diff_add_bg = "#a4dfae33",
  diff_add_txt = "#a4dfae66",
  diff_del_bg = "#edabab33",
  diff_del_txt = "#edabab66",

  -- Messages / diagnostics
  err = "#edabab",
  warn = "#eecfa0",
  info = "#8fc7ff",
  hint = "#a1e8e5",
  ok = "#a4dfae",

  -- Menu / lists / misc
  list_sel_bg = "#334155",
  list_focus_bg = "#293545",
  list_hover_bg = "#2d3a4b",
  list_inactive_sel_bg = "#283242",
  list_drop_bg = "#232a39",

  -- Accents seen in tokenColors
  accent_num = "#d5f288",   -- numeric
  accent_prop = "#ded6cf",
  accent_ns = "#e3cbeb",
  accent_tag = "#edabab",
  accent_kw = "#d2ccff",
  accent_fn = "#8fc7ff",
  accent_str = "#a4dfae",
  accent_attr = "#eecfa0",
  accent_punct = "#b8d7f9",
}

-- === Alpha-aware HEX normalizer for Neovim ===
local function hex_to_rgb(h)
  h = h:gsub("#","")
  return tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16)
end

local function rgb_to_hex(r,g,b)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Blend fg( may be #RRGGBB or #RRGGBBAA ) over bg(#RRGGBB).
local function blend_over(bg_hex, fg_hex)
  if type(fg_hex) ~= "string" or fg_hex:sub(1,1) ~= "#" then return fg_hex end
  local s = fg_hex:gsub("#","")
  if #s == 6 then return "#" .. s end
  if #s ~= 8 then return "#" .. s:sub(1,6) end
  local fr, fg_, fb = tonumber(s:sub(1,2),16), tonumber(s:sub(3,4),16), tonumber(s:sub(5,6),16)
  local a = tonumber(s:sub(7,8),16) / 255.0
  local br, bg_, bb = hex_to_rgb(bg_hex)
  local r = math.floor(br + (fr - br) * a + 0.5)
  local g = math.floor(bg_ + (fg_ - bg_) * a + 0.5)
  local b = math.floor(bb + (fb - bb) * a + 0.5)
  return rgb_to_hex(r,g,b)
end

-- Normalize a color string: if it's #RRGGBBAA, pre-blend onto the main editor bg.
local function norm(col)
  if type(col) ~= "string" then return col end
  if not col:match("^#%x%x%x%x%x%x%x%x$") then return col end
  return blend_over(p.bg, col)
end

-- Replace your hi() with alpha-safe version
local function hi(group, opts)
  local o = {}
  for k,v in pairs(opts) do
    if (k == "fg" or k == "bg" or k == "sp") and type(v) == "string" then
      o[k] = norm(v)
    else
      o[k] = v
    end
  end
  vim.api.nvim_set_hl(0, group, o)
end

function M.setup()
  if vim.g.colors_name then vim.cmd("hi clear") end
  vim.o.termguicolors = true
  vim.g.colors_name = p.name

  -- terminal palette
  vim.g.terminal_color_0  = p.t_black
  vim.g.terminal_color_1  = p.t_red
  vim.g.terminal_color_2  = p.t_green
  vim.g.terminal_color_3  = p.t_yellow
  vim.g.terminal_color_4  = p.t_blue
  vim.g.terminal_color_5  = p.t_magenta
  vim.g.terminal_color_6  = p.t_cyan
  vim.g.terminal_color_7  = p.t_white
  vim.g.terminal_color_8  = p.t_bblack
  vim.g.terminal_color_9  = p.t_bred
  vim.g.terminal_color_10 = p.t_bgreen
  vim.g.terminal_color_11 = p.t_byellow
  vim.g.terminal_color_12 = p.t_bblue
  vim.g.terminal_color_13 = p.t_bmagenta
  vim.g.terminal_color_14 = p.t_bcyan
  vim.g.terminal_color_15 = p.t_bwhite

  -- Core editor
  hi("Normal",         { fg = p.fg, bg = p.bg })
  hi("NormalFloat",    { fg = p.fg, bg = p.tabs_bg })
  hi("FloatBorder",    { fg = p.widget_border, bg = p.tabs_bg })
  hi("ColorColumn",    { bg = p.tabs_bg })
  hi("Cursor",         { fg = p.bg, bg = p.cursor })
  hi("lCursor",        { fg = p.bg, bg = p.cursor })
  hi("TermCursor",     { fg = p.bg, bg = p.cursor })
  hi("CursorLine",     { bg = p.linehl_bg })
  hi("CursorLineNr",   { fg = p.linenr_fg_active, bg = p.linehl_bg, bold = true })
  hi("LineNr",         { fg = p.linenr_fg, bg = p.bg })
  hi("SignColumn",     { fg = p.linenr_fg, bg = p.bg })
  hi("Visual",         { bg = p.selection_bg, fg = p.bg })
  hi("VisualNOS",      { bg = p.selection_bg_inactive, fg = p.bg })
  hi("Search",         { bg = p.find_bg, fg = p.fg })
  hi("IncSearch",      { bg = p.find_hl_bg, fg = p.fg })
  hi("MatchParen",     { bg = p.hover_bg, bold = true })
  hi("WinSeparator",   { fg = p.tabs_border })
  hi("VertSplit",      { fg = p.tabs_border, bg = p.bg })
  hi("Pmenu",          { fg = p.fg, bg = p.tabs_bg, blend = 0 })
  hi("PmenuSel",       { fg = p.bg, bg = p.list_sel_bg, bold = true })
  hi("PmenuSbar",      { bg = p.tabs_bg })
  hi("PmenuThumb",     { bg = p.widget_border })
  hi("StatusLine",     { fg = p.fg, bg = p.tabs_bg, bold = true })
  hi("StatusLineNC",   { fg = p.linenr_fg, bg = p.tabs_bg })
  hi("TabLine",        { fg = p.linenr_fg, bg = p.tabs_bg })
  hi("TabLineSel",     { fg = p.bg, bg = p.list_sel_bg, bold = true })
  hi("TabLineFill",    { fg = p.linenr_fg, bg = p.tabs_bg })
  hi("Folded",         { fg = p.fg, bg = p.tabs_bg })
  hi("FoldColumn",     { fg = p.linenr_fg, bg = p.bg })
  hi("Whitespace",     { fg = p.indent })

  -- Lists / quickfix-like
  hi("QuickFixLine",   { bg = p.list_focus_bg })
  hi("WildMenu",       { fg = p.bg, bg = p.list_sel_bg, bold = true })

  -- Messages
  hi("ErrorMsg",       { fg = p.bg, bg = p.err, bold = true })
  hi("WarningMsg",     { fg = p.bg, bg = p.warn, bold = true })
  hi("MoreMsg",        { fg = p.ok })
  hi("ModeMsg",        { fg = p.accent_fn, bold = true })
  hi("Question",       { fg = p.ok, bold = true })
  hi("Todo",           { fg = p.bg, bg = p.warn, bold = true })

  -- Syntax (vim default groups)
  hi("Comment",        { fg = "#999999", italic = true })
  hi("Constant",       { fg = p.accent_attr })    -- constants lean warm
  hi("String",         { fg = p.accent_str })
  hi("Character",      { fg = p.accent_str })
  hi("Number",         { fg = p.accent_num })
  hi("Boolean",        { fg = p.accent_kw, bold = true })
  hi("Float",          { fg = p.accent_num })

  hi("Identifier",     { fg = p.accent_attr })    -- generic identifiers -> warm sand
  hi("Function",       { fg = p.accent_fn, bold = true })

  hi("Statement",      { fg = p.accent_kw, italic = true })
  hi("Conditional",    { fg = p.accent_kw, italic = true })
  hi("Repeat",         { fg = p.accent_kw, italic = true })
  hi("Label",          { fg = p.accent_kw })
  hi("Operator",       { fg = p.accent_punct })
  hi("Keyword",        { fg = p.accent_kw, italic = true })
  hi("Exception",      { fg = p.accent_kw })

  hi("PreProc",        { fg = p.accent_attr })
  hi("Include",        { fg = p.accent_kw })
  hi("Define",         { fg = p.accent_kw })
  hi("Macro",          { fg = p.accent_kw })
  hi("PreCondit",      { fg = p.accent_kw })

  hi("Type",           { fg = p.accent_attr, bold = true })
  hi("StorageClass",   { fg = p.accent_kw, italic = true })
  hi("Structure",      { fg = p.accent_attr })
  hi("Typedef",        { fg = p.accent_attr })

  hi("Special",        { fg = p.accent_punct })
  hi("SpecialComment", { fg = "#999999", italic = true })
  hi("Underlined",     { underline = true })
  hi("Bold",           { bold = true })
  hi("Italic",         { italic = true })

  -- Diagnostics (LSP)
  hi("DiagnosticError", { fg = p.err })
  hi("DiagnosticWarn",  { fg = p.warn })
  hi("DiagnosticInfo",  { fg = p.info })
  hi("DiagnosticHint",  { fg = p.hint })
  hi("DiagnosticOk",    { fg = p.ok })
  hi("DiagnosticUnderlineError", { sp = p.err, undercurl = true })
  hi("DiagnosticUnderlineWarn",  { sp = p.warn, undercurl = true })
  hi("DiagnosticUnderlineInfo",  { sp = p.info, undercurl = true })
  hi("DiagnosticUnderlineHint",  { sp = p.hint, undercurl = true })
  hi("LspReferenceText",  { bg = p.range_bg })
  hi("LspReferenceRead",  { bg = p.range_bg })
  hi("LspReferenceWrite", { bg = p.range_bg })
  hi("LspInlayHint", { fg = p.inlay_fg, bg = p.inlay_bg, italic = true })

  -- Git / VCS
  hi("GitSignsAdd",    { fg = p.ok, bg = p.bg })
  hi("GitSignsChange", { fg = p.info, bg = p.bg })
  hi("GitSignsDelete", { fg = p.err, bg = p.bg })
  hi("DiffAdd",        { bg = p.diff_add_bg, fg = p.ok })
  hi("DiffChange",     { bg = p.linehl_bg,   fg = p.info })
  hi("DiffDelete",     { bg = p.diff_del_bg, fg = p.err })
  hi("DiffText",       { bg = p.selection_bg_soft, fg = p.warn, bold = true })

  -- Treesitter & LSP semantic mappings (best-effort to mirror JSON)
  local links = {
    ["@comment"]                 = "Comment",
    ["@punctuation"]             = "Operator",
    ["@punctuation.bracket"]     = "Operator",
    ["@operator"]                = "Operator",

    ["@string"]                  = "String",
    ["@string.regex"]            = "String",
    ["@character"]               = "Character",
    ["@number"]                  = "Number",
    ["@float"]                   = "Float",
    ["@boolean"]                 = "Boolean",
    ["@constant"]                = "Constant",
    ["@constant.builtin"]        = "Constant",

    ["@variable"]                = "Identifier",
    ["@variable.parameter"]      = "Identifier",
    ["@variable.member"]         = "Identifier",
    ["@property"]                = "Identifier",
    ["@field"]                   = "Identifier",

    ["@function"]                = "Function",
    ["@function.builtin"]        = "Function",
    ["@constructor"]             = "Function",
    ["@method"]                  = "Function",

    ["@type"]                    = "Type",
    ["@type.builtin"]            = "Type",
    ["@type.definition"]         = "Typedef",
    ["@type.qualifier"]          = "StorageClass",
    ["@namespace"]               = "Identifier",

    ["@keyword"]                 = "Keyword",
    ["@keyword.function"]        = "Keyword",
    ["@keyword.operator"]        = "Operator",
    ["@keyword.import"]          = "Include",
  }
  for k, v in pairs(links) do hi(k, { link = v }) end

  -- Extra accent mappings to emulate tokenColors vibe
  hi("@number",           { fg = p.accent_num })
  hi("@punctuation.delimiter", { fg = p.accent_punct })
  hi("@punctuation.special",   { fg = p.accent_punct })
  hi("@tag",              { fg = p.accent_tag })
  hi("@tag.attribute",    { fg = p.accent_attr })
  hi("@tag.delimiter",    { fg = p.accent_punct })
  hi("@keyword.return",   { fg = p.accent_kw, italic = true })
  hi("@keyword.exception",{ fg = p.accent_kw, italic = true })
  hi("@variable.parameter",{ fg = p.accent_attr, underline = true })
  hi("@variable.member",  { fg = p.accent_prop })
  hi("@property",         { fg = p.accent_prop })
  hi("@namespace",        { fg = p.accent_ns, bold = true })
  hi("@type",             { fg = p.accent_attr, bold = true })
  hi("@type.parameter",   { fg = p.accent_attr, bold = true })
  hi("@function",         { fg = p.accent_fn, bold = true })
  hi("@function.method",  { fg = p.accent_fn, bold = true })

  -- LSP semantic tokens (Neovim >=0.9 exposes @lsp.type.*)
  local lsp_links = {
    ["@lsp.type.namespace"]   = "@namespace",
    ["@lsp.type.class"]       = "@type",
    ["@lsp.type.struct"]      = "@type",
    ["@lsp.type.enum"]        = "@type",
    ["@lsp.type.interface"]   = "@type",
    ["@lsp.type.type"]        = "@type",
    ["@lsp.type.parameter"]   = "@variable.parameter",
    ["@lsp.type.property"]    = "@property",
    ["@lsp.type.enumMember"]  = "@constant",
    ["@lsp.type.function"]    = "@function",
    ["@lsp.type.method"]      = "@function",
    ["@lsp.type.macro"]       = "Macro",
    ["@lsp.type.keyword"]     = "Keyword",
    ["@lsp.type.modifier"]    = "StorageClass",
    ["@lsp.type.operator"]    = "Operator",
    ["@lsp.type.typeParameter"]= "@type.parameter",
    ["@lsp.type.variable"]    = "Identifier",
  }
  for k, v in pairs(lsp_links) do hi(k, { link = v }) end

  -- Telescope (generic)
  hi("TelescopeNormal",    { fg = p.fg, bg = p.tabs_bg })
  hi("TelescopeBorder",    { fg = p.widget_border, bg = p.tabs_bg })
  hi("TelescopeSelection", { bg = p.selection_bg, fg = p.bg, bold = true })
  hi("TelescopeMatching",  { fg = p.accent_fn, bold = true })

  -- File tree (NvimTree / Neo-tree)
  hi("NvimTreeNormal",     { fg = p.fg, bg = p.tabs_bg })
  hi("NvimTreeVertSplit",  { fg = p.tabs_border, bg = p.bg })
  hi("NvimTreeFolderName", { fg = p.t_blue })
  hi("NvimTreeRootFolder", { fg = p.t_bblue, bold = true })
  hi("NvimTreeGitDirty",   { fg = p.warn })
  hi("NvimTreeGitNew",     { fg = p.ok })
  hi("NvimTreeGitDeleted", { fg = p.err })

  -- Indent guides
  hi("IndentBlanklineChar",        { fg = p.indent })
  hi("IndentBlanklineContextChar", { fg = p.indent_active })

  -- Misc UI parity
  hi("Title",          { fg = p.accent_kw, bold = true })
  hi("Directory",      { fg = p.t_blue })
  hi("Underlined",     { underline = true })
end

M.setup()

return M
