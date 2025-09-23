set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim

call plug#begin("~/.vim/plugged")
  Plug 'olimorris/onedarkpro.nvim'
  Plug 'itchyny/lightline.vim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'tpope/vim-sensible'
  Plug 'f-person/git-blame.nvim'
  Plug 'ap/vim-css-color'
  Plug 'octol/vim-cpp-enhanced-highlight'
  Plug 'haishanh/night-owl.vim'
call plug#end()

" Plugin settings
" Git blame
let g:gitblame_message_template = '  <author>, <date> • <summary>'
let g:gitblame_date_format = '%r'

syntax enable
" colorscheme onedark_dark
" colorscheme maple-dark
colorscheme night-owl

let g:lightline = {
      \ 'colorscheme': 'one',
     \ }
set noshowmode " remove showing --INSERT--
