set encoding=utf-8
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
filetype plugin indent on

syntax on
let mapleader=";"

"-------
" YouCompleteMe
"------
" Plug 'Valloric/YouCompleteMe'
let g:ycm_goto_buffer_command='vertical-split'
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_semantic_triggers =  {
			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			\ 'cs,lua,javascript': ['re!\w{2}'],
			\ }


let g:ycm_filetype_whitelist = {
            \ "c":1,
            \ "cpp":1,
            \ "go":1,
            \ "rust":1,
            \}



"--------
" Vim UI
"--------
" color scheme
set background=dark

au WinEnter * set cursorline
au WinNew * set cursorline
set cursorline

"--------------
" IDE features
"--------------
Plug 'scrooloose/nerdtree'
Plug 'kien/ctrlp.vim'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


let g:airline_theme='simple'
let g:EasyGrepFilesToExclude="tags"


"-------------
" Other Utils
" search
set incsearch
set hlsearch
set ignorecase
set smartcase

set showcmd                                                       " show typed command in status bar
set title                                                         " show file in titlebar

" Default Indentation
set autoindent
set smartindent     " indent when
set tabstop=4       " tab width
set softtabstop=4   " backspace
set shiftwidth=4    " indent width
set expandtab       " expand tab to space

let g:rbpt_max = 16


" Nerd Tree
let NERDChristmasTree=0
let NERDTreeWinSize=30
let NERDTreeChDirMode=2
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']
let NERDTreeShowBookmarks=1
let NERDTreeWinPos = "right"


" ctrlp
set wildignore+=*/tmp/*,*.so,*.o,*.a,*.obj,*.swp,*.zip,*.pyc,*.pyo,*.class,.DS_Store  " MacOSX/Linux
let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'

call plug#end()

" colorscheme gruvbox
set guioptions=
set background=dark
hi CursorLine cterm=none ctermbg=DarkGrey ctermfg=White
