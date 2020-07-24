set mouse=
set ttymouse=
set paste
set binary
set noendofline
set nobackup
set backupdir=~/.vim/tmp
set autowrite
set encoding=utf-8
set undofile
set undodir=~/.vim/tmp
set directory=~/.vim/tmp

set hidden
set lazyredraw
set splitbelow
set splitright
set scrolloff=5
set nostartofline

set autoindent
set smartindent
set cindent

set t_Co=256

set noerrorbells
set novisualbell

" Text formatting
set wrap
set textwidth=80

set colorcolumn=95

" Tabs
set noexpandtab
set smarttab
set shiftround
set tabstop=2
set ts=2
set shiftwidth=2
set softtabstop=2

" Don't care about vi
set nocompatible

" Security
set modelines=0

syntax on


" Shortcuts

nnoremap ; :

" Change leader key
let mapleader=","

" ,c - create tab
nnoremap <silent> <leader>c :tabnew<cr>
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h
noremap <leader>n gt
noremap <leader>p gT


" ,v - split vertically
nnoremap <silent> <leader>v :vsplit<cr>
" ,h - split horizontally
nnoremap <silent> <leader>h :split<cr>

" ,w - write file
nnoremap <silent> <leader>w :write<cr>

" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>


