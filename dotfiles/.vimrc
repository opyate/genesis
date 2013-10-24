execute pathogen#infect()
syntax on
filetype plugin indent on

" close NERDTree if it is the only thing remaining
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" find default tags
set tags=./tags,tags
set hidden
set number
set ignorecase
set showmatch
set hlsearch
set incsearch
set nobackup
set noswapfile
