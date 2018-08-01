set nu
set ai
set cursorline
set tabstop=4
set paste
set hlsearch
set ignorecase
set expandtab

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ }


" Plugin configuration
call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'itchyny/lightline.vim'
Plug 'Valloric/YouCompleteMe', { 'for': 'go' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

colorscheme onedark
syntax enable

" NERDTree config
"open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"map F2 to open NERDTree
map <F2> :NERDTreeToggle<CR>
"close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4
autocmd FileType go set expandtab

set completeopt=longest,menu

tnoremap <Esc> <C-\><C-n>
nnoremap <Tab> <C-W>w
nnoremap <Tab> <C-W><C-W>
inoremap <Tab> <C-W>w
inoremap <Tab> <C-W><C-W>
nnoremap <C-w>o :below 10sp term://$SHELL<cr>
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

autocmd BufEnter term://* startinsert

