" Vundle setup
set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'Valloric/YouCompleteMe'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'w0rp/ale'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" My settings follow
if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab

" working with the system clipboard (requires vim-gtk3)
set clipboard=unnamedplus

" Markdown syntax highlighting
autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" YML editing options
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2

set ignorecase 
set hlsearch
set incsearch
set smartcase
set number
set relativenumber
set nowrap

" buffers are hidden, not closed when swithich to a different one; preserves undo history
set hidden

" show commands as they are being typed
set showcmd

" always display the status line
set laststatus=2

colorscheme darcula
syntax enable

" disable background color settings, so it can be transparent
highlight Normal guibg=NONE ctermbg=NONE

" Coloring syntax on long lines is really slow for some reason.
" This limits coloring.
" It's not so bad with Neovim. It'll probably gonna be better to limit the
" coloring only when needed.
" set synmaxcol=150

" spell-checking
set spell spelllang=en_us
set spellfile=~/.vim/en.utf-8.add

" keybindings for YouCompleteMe, leader is space
let mapleader = " "
nnoremap <leader>d :YcmCompleter GoToDefinition<CR>
nnoremap <leader>c :YcmCompleter GetDoc<CR>
nnoremap <leader>r :YcmCompleter GoToReferences<CR>

" jumping around the quickfix list
nnoremap <leader>j :cn<CR>
nnoremap <leader>k :cp<CR>

" jumping around the location list
nnoremap <leader>J :lnext<CR>
nnoremap <leader>K :lprev<CR>

" keybindings for CtrlP
nnoremap <leader>. :CtrlP<CR>
nnoremap <leader>, :CtrlPBuffer<CR>

" useful keybindings for basic operations
nnoremap <leader>q :bd<CR>
nnoremap <leader>s :w<CR>

" Search for occurences of a word in python files, don't jump to first found immediately (j), but
" open the quickfix list (cw).
" Should use that when YouCompleteMe fails to find references.
nnoremap <leader>f :execute "vimgrep /" . expand("<cword>") . "/j **/*.py"<Bar>cw<CR>

" making YouCompleteMe work nicely with virtualenv
let g:ycm_python_binary_path = 'python'

" ALE configuration
" TODO if pylint is not available, use pycodestyle
let g:ale_linters = {
\   'python': ['pylint'],
\}
