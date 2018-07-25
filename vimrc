set nu
set ai
set cursorline
set tabstop=4
set shiftwidth=4
set hlsearch
set ignorecase
set expandtab

inoremap ( ()<Esc>i
inoremap " ""<Esc>i
inoremap ' ''<Esc>i
inoremap [ []<Esc>i
inoremap {<CR> {<CR>}<Esc>i
inoremap {{ {}<ESC>i

filetype indent on

" Color configuration
set bg=dark
color evening  " Same as :colorscheme evening
hi LineNr cterm=bold ctermfg=DarkGrey ctermbg=NONE
hi CursorLineNr cterm=bold ctermfg=Green ctermbg=NONE


