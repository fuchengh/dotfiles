" ===================== Basics ======================
" Modern defaults for Neovim
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

" Colors (pick one)
" colorscheme onedark_dark
colorscheme night-owl

" ===================== Plugins =====================
call plug#begin("~/.vim/plugged")
  Plug 'olimorris/onedarkpro.nvim'
  Plug 'itchyny/lightline.vim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'tpope/vim-sensible'
  Plug 'f-person/git-blame.nvim'
  Plug 'ap/vim-css-color'
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'haishanh/night-owl.vim'

  " --- VS Code-like essentials ---
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'                   " Ctrl+P / Ctrl+F
  Plug 'nvim-tree/nvim-tree.lua'                         " Ctrl+B
  Plug 'nvim-tree/nvim-web-devicons'                     " icons
  Plug 'folke/which-key.nvim'                            " key-hints
  Plug 'numToStr/Comment.nvim'                           " Ctrl+/
  Plug 'mg979/vim-visual-multi'                          " Ctrl+D multi-cursor
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  " --- LSP baseline (C/C++ ready) ---
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'
call plug#end()

" ===================== Plugin Config =====================
" Git blame (inline)
let g:gitblame_message_template = '  <author>, <date> • <summary>'
let g:gitblame_date_format = '%r'

" Lightline minimal theme
let g:lightline = { 'colorscheme': 'one' }
set noshowmode " hide -- INSERT --

" Treesitter (better highlight; safe defaults)
lua << EOF
require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "bash", "python", "json" },
  highlight = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = true }
})
EOF

" Telescope: VS Code-style pickers
nnoremap <C-p> :Telescope find_files<CR>
nnoremap <C-f> :Telescope live_grep<CR>         " requires ripgrep (rg)
nnoremap <leader>r :Telescope oldfiles<CR>
nnoremap <leader>P :Telescope commands<CR>      " Command Palette alternative to Ctrl+Shift+P
nnoremap <leader>fb :Telescope buffers<CR>

" NvimTree: Explorer on Ctrl+B
nnoremap <C-b> :NvimTreeToggle<CR>
lua << EOF
require('nvim-tree').setup({
  view = { width = 36 },
  renderer = { highlight_git = true, icons = { show = { git = true } } },
  git = { enable = true }
})
EOF

" Which-Key (leader hints)
lua << EOF
require('which-key').setup({})
EOF
let mapleader=" "  " Space as leader (needed by which-key)

" Comment.nvim: Ctrl-/ toggle (Ctrl-_ == Ctrl-/ in most terminals)
lua << EOF
require('Comment').setup()
EOF
nnoremap <silent> <C-_> :lua require('Comment.api').toggle.linewise.current()<CR>
xnoremap <silent> <C-_> :<C-u>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>

" Gitsigns
lua << EOF
require('gitsigns').setup({
  signs = {
    add = {text = '+'}, change = {text = '~'}, delete = {text = '_'},
    topdelete = {text = '‾'}, changedelete = {text = '~'}
  },
  current_line_blame = false
})
EOF

" LSP: mason + clangd + keymaps similar to VS Code
lua << EOF
local ok_mason, mason = pcall(require, 'mason')
if ok_mason then mason.setup() end
local ok_mlsp, mlsp = pcall(require, 'mason-lspconfig')
if ok_mlsp then mlsp.setup({ ensure_installed = { "clangd" } }) end

local lspconfig = require('lspconfig')
local on_attach = function(_, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
  -- VS Code-ish keys
  vim.keymap.set('n', 'K',         vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<F2>',      vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<F12>',     vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<S-F12>',   require('telescope.builtin').lsp_references, opts)
  vim.keymap.set('n', '<M-CR>',    vim.lsp.buf.code_action, opts)  -- Alt+Enter
  vim.keymap.set('n', '[d',        vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d',        vim.diagnostic.goto_next, opts)
end

-- clangd defaults are good for C/C++
if lspconfig.clangd then
  lspconfig.clangd.setup({ on_attach = on_attach })
end
EOF

" Visual Multi: make Ctrl-D behave like VS Code 'Add Selection to Next Match'
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'

" ===================== VS Code-like Keymaps =====================
" Save
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <C-c>:w<CR>

" Better window nav (Ctrl+h/j/k/l)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Quick toggle terminal (use leader since Ctrl-` is unreliable in terminals)
nnoremap <leader>t :terminal<CR>

" ===================== Cleanup of duplicates/legacy =====================
" Remove legacy/duplicates from your old config:
" - 'set ttyfast' is obsolete
" - avoid both 'mouse=v' and 'mouse=a' (use mouse=a)
" - avoid duplicate 'filetype plugin' lines; Neovim enables filetype by default
syntax enable
filetype plugin indent on