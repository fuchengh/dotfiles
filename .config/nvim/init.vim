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
nnoremap <leader>t :terminal<CR>
" Comment.nvim toggles (Ctrl-/ is Ctrl-_ in terminals)
nnoremap <silent> <C-_> :lua require('Comment.api').toggle.linewise.current()<CR>
xnoremap <silent> <C-_> :<C-u>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>
" Visual Multi: Ctrl-D like VS Code
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'

" ===================== Safe Lua config (ONE block) =====================
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
  local ok, nvimtree = has('nvim-tree')
  if ok then
    nvimtree.setup({
      view = { width = 36 },
      renderer = { highlight_git = true, icons = { show = { git = true } } },
      git = { enable = true },
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
EOF

syntax enable
filetype plugin indent on
