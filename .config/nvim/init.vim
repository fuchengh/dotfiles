" ===================== Basics ======================
set number
set cursorline
set mouse=a
set clipboard=unnamedplus
set ignorecase
set smartcase
set incsearch
set hlsearch
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set wildmode=longest:full,full
set splitright
set splitbelow
set signcolumn=yes
set termguicolors
set updatetime=200
set completeopt=menu,menuone,noselect
set undofile
" Always show tabline (for Bufferline)
set showtabline=2

let mapleader = " "

" ===================== vim-plug bootstrap =====================
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
  silent execute '!curl -fsSLo ' . stdpath('data') . '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  au VimEnter * ++once PlugInstall --sync | qa
endif

" ===================== Plugins =====================
call plug#begin(stdpath('data') . '/plugged')
  " themes/status/git
  Plug 'olimorris/onedarkpro.nvim'
  Plug 'haishanh/night-owl.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'f-person/git-blame.nvim'

  " misc
  Plug 'tpope/vim-sensible'
  Plug 'ap/vim-css-color'
  Plug 'octol/vim-cpp-enhanced-highlight'

  " VS Code-like
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-tree/nvim-tree.lua'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/which-key.nvim'
  Plug 'numToStr/Comment.nvim'
  Plug 'mg979/vim-visual-multi'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'akinsho/bufferline.nvim', {'tag': '*'}
  Plug 'petertriho/nvim-scrollbar'
  Plug 'gorbit99/codewindow.nvim'

  " LSP baseline
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'
call plug#end()

" Auto-install missing plugins (first run)
if len(filter(values(g:plugs), {_, v -> !isdirectory(v.dir)}))
  autocmd VimEnter * ++once PlugInstall --sync | qa
endif

" ===================== UI/Colors =====================
try
  colorscheme night-owl
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
endtry
let g:lightline = { 'colorscheme': 'one' }
set noshowmode
let g:gitblame_message_template = '  <author>, <date> • <summary>'
let g:gitblame_date_format = '%r'

" ===================== Keymaps (VS Code-ish) =====================
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <C-c>:w<CR>
nnoremap <C-p> :Telescope find_files<CR>
nnoremap <C-f> :Telescope live_grep<CR>
nnoremap <leader>fb :Telescope buffers<CR>
nnoremap <leader>P  :Telescope commands<CR>
nnoremap <C-b> :NvimTreeToggle<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" ==== Comment.nvim toggles (Ctrl-/) like VS Code ====
nnoremap <silent> <C-/> :lua require('Comment.api').toggle.linewise.current()<CR>
xnoremap <silent> <C-/> :<C-u>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>
" Visual Multi: Ctrl-D like VS Code
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'
" ==== Toggle terminal like VS Code ====
" Normal/Terminal: Ctrl-\ to toggle
nnoremap <silent> <C-\> :lua ToggleTermBottom()<CR>
tnoremap <silent> <C-\> <C-\><C-n>:lua ToggleTermBottom()<CR>
" Optional: try Ctrl-` if your GUI/terminal can send it (many terminals can't)
" You can keep these; they only work where supported.
nnoremap <silent> <C-`> :lua ToggleTermBottom()<CR>
tnoremap <silent> <C-`> <C-\><C-n>:lua ToggleTermBottom()<CR>
" Optional: Alt-` (often works across terminals)
nnoremap <silent> <M-`> :lua ToggleTermBottom()<CR>
tnoremap <silent> <M-`> <C-\><C-n>:lua ToggleTermBottom()<CR>
" ==== Quit from anywhere ====
" Normal/Insert: Ctrl-Q to force quit all
nnoremap <silent> <C-Q> :qa!<CR>
inoremap <silent> <C-Q> <Esc>:qa!<CR>
" Terminal-Job: Esc to normal, Ctrl-Q quit
tnoremap <Esc> <C-\><C-n>
tnoremap <silent> <C-Q> <C-\><C-n>:qa!<CR>
" ==== Tab switch (next/prev tab) ====
" Primary: Shift-l / Shift-h for next/prev
nnoremap <silent> <Tab> :tabNext<CR>
nnoremap <silent> <S-Tab> :tabprevious<CR>
" Ctrl + <-/->
nnoremap <silent> <C-Right> :tabNext<CR>
nnoremap <silent> <C-Left>  :tabprevious<CR>

" ===================== Safe Lua config (put lua functions here) =====================
lua <<EOF
local function has(mod) local ok, m = pcall(require, mod); return ok, m end

-- Treesitter
do
  local ok, ts = has('nvim-treesitter.configs')
  if ok then
    ts.setup({
      ensure_installed = { "c","cpp","lua","vim","vimdoc","bash","python","json" },
      highlight = { enable = true },
      incremental_selection = { enable = true },
      indent = { enable = true },
    })
  end
end

-- NvimTree
do
  local ok, nvimtree = pcall(require, 'nvim-tree')
  if ok then
    local api = require('nvim-tree.api')

    local function my_on_attach(bufnr)
      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      -- Open in a new tab and jump to it (t to open in new tab, T to open and stay in nvim-tree)
      vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))
      -- Open in a new tab but keep focus on the tree
      vim.keymap.set('n', 'T', function()
        api.node.open.tab()
        api.tree.focus()
      end, opts('Open: New Tab (stay)'))

      -- Optional: vertical/horizontal split tab
      -- vim.keymap.set('n', '<C-v>', api.node.open.vertical,   opts('Open: Vertical Split'))
      -- vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
      vim.keymap.set('n', '<CR>',  api.node.open.edit,       opts('Open: Edit'))
    end

    nvimtree.setup({
      on_attach = my_on_attach,
      view = { width = 36 },
      renderer = { highlight_git = true, icons = { show = { git = true } } },
      git = { enable = true },
      actions = {
        open_file = {
          quit_on_open = false,   -- set true if you want the tree to close after opening
          resize_window = true,
        },
      },
    })
  end
end

-- Which-Key / Comment / Gitsigns
pcall(function() require('which-key').setup({}) end)
pcall(function() require('Comment').setup() end)
pcall(function()
  require('gitsigns').setup({
    signs = {
      add = {text = '+'}, change = {text = '~'}, delete = {text = '_'},
      topdelete = {text = '‾'}, changedelete = {text = '~'}
    },
    current_line_blame = false,
  })
end)

-- Mason + LSP (clangd) with VS Code-ish maps
do
  local ok_mason, mason = has('mason'); if ok_mason then mason.setup() end
  local ok_mlsp, mlsp = has('mason-lspconfig')
  if ok_mlsp then mlsp.setup({ ensure_installed = { "clangd" } }) end

  local ok_lsp, lspconfig = has('nvim-lspconfig')
  local tel_ok, tb = pcall(require, 'telescope.builtin')
  if ok_lsp then
    local on_attach = function(_, bufnr)
      local o = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n','K',       vim.lsp.buf.hover, o)
      vim.keymap.set('n','<F2>',    vim.lsp.buf.rename, o)
      vim.keymap.set('n','<F12>',   vim.lsp.buf.definition, o)
      if tel_ok then
        vim.keymap.set('n','<S-F12>', tb.lsp_references, o)
      end
      vim.keymap.set('n','<M-CR>',  vim.lsp.buf.code_action, o)
      vim.keymap.set('n','[d',      vim.diagnostic.goto_prev, o)
      vim.keymap.set('n',']d',      vim.diagnostic.goto_next, o)
    end
    if lspconfig.clangd then
      lspconfig.clangd.setup({ on_attach = on_attach })
    end
  end
end

-- Toggle a bottom terminal: if any terminal window exists in current tab,
-- close it; otherwise open a 12-line split and start in insert (job) mode.
function ToggleTermBottom()
  local api = vim.api
  local cur_tab = api.nvim_get_current_tabpage()
  for _, win in ipairs(api.nvim_tabpage_list_wins(cur_tab)) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      api.nvim_win_close(win, true)
      return
    end
  end
  vim.cmd('botright 12split | terminal')
  vim.cmd('startinsert')  -- ensure you can type commands immediately
end

-- Bufferline (VS Code-like tabs)
do
  local ok, bufferline = pcall(require, 'bufferline')
  if ok then
    bufferline.setup({
      options = {
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        separator_style = 'thin',
        offsets = {
          { filetype = 'NvimTree', text = 'Explorer', highlight = 'Directory', separator = true },
        },
      },
    })
  end
end

-- Scrollbar with Git/diagnostics/search marks
do
  local ok, scrollbar = pcall(require, 'nvim-scrollbar')
  if ok then
    scrollbar.setup({
      handle = { blend = 20 }, -- subtle handle
      marks = {
        Search = { text = { '•' } },
        Error = { text = { '▎' } },
        Warn  = { text = { '▎' } },
        Info  = { text = { '▎' } },
        Hint  = { text = { '▎' } },
        Misc  = { text = { '▎' } },
      },
      handlers = { cursor = true, diagnostic = true, gitsigns = true, search = true },
    })
    -- Enable Git hunk marks on scrollbar (requires lewis6991/gitsigns.nvim)
    pcall(function() require('scrollbar.handlers.gitsigns').setup() end)
  end
end

-- Minimap (codewindow) - auto enable, integrates with Treesitter; keep it lightweight
do
  local ok, codewindow = pcall(require, 'codewindow')
  if ok then
    codewindow.setup({
      auto_enable = true,
      minimap_width = 8,
      use_treesitter = true,
      exclude_filetypes = { 'NvimTree', 'help', 'terminal' },
      window_border = 'single',
      z_index = 2,
      -- NOTE: Git change colors are shown on the scrollbar via gitsigns.
      -- Minimap focuses on code overview for performance.
    })
    -- Optional default keybinds: toggle/show/hide (can keep; your own toggle also exists)
    -- codewindow.apply_default_keybinds()
  end
end
EOF

syntax enable
filetype plugin indent on
