# dotfiles

My dotfiles

- Run: `./setup.sh`
- Change p10k settings: `p10k configure`

## Neovim Keybindings

Leader key: `<Space>`

Prerequisites:

- ripgrep (for Telescope live_grep)
- Optional: clangd

```text
BASICS / FILE & SEARCH
  Mode   Key               Description
  ------------------------------------
- N/I/V  Ctrl+S            Save
- N      Ctrl+P            File search (Telescope find_files)
- N      Ctrl+F            Global search (Telescope live_grep)
- N      <Space> f b       Buffer picker (Telescope buffers)
- N      <Space> P         Command palette (Telescope commands)

EXPLORER / WINDOW NAVIGATION
  Mode   Key               Description
  ------------------------------------
- N      Ctrl+B            Toggle file explorer (NvimTreeToggle)
- N      Ctrl+H/J/K/L      Move focus left/down/up/right (window navigation)

COMMENT / MULTI-CURSOR / TERMINAL
  Mode   Key               Description
  ------------------------------------
- N      Ctrl+/            Toggle line comment (Comment.nvim)
- V      Ctrl+/            Toggle block comment (Comment.nvim)
- N      Ctrl+D            Add selection to next match (vim-visual-multi)
- N      <Space> t         Open terminal (:terminal)

LSP (when language server is attached)
  Mode   Key               Description
  ------------------------------------
- N      K                 Hover documentation
- N      F2                Rename symbol
- N      F12               Go to definition
- N      Shift+F12         Find references (Telescope)
- N      Alt+Enter         Code action
- N      [d / ]d           Previous / next diagnostic
```
