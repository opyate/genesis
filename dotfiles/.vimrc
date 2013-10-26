execute pathogen#infect()
syntax on
filetype plugin indent on

" System default for mappings is now the "," character
let mapleader = ","

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

" Add xptemplate global personal directory value
if has("unix")
  set runtimepath+=~/.vim/xpt-personal
endif

" Tabstops are 4 spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent


" set the search scan to wrap lines
set wrapscan

" visual bell
set vb

" Allow backspacing over indent, eol, and the start of an insert
set backspace=2

" Set the status line the way i like it
set stl=%f\ %m\ %r%{fugitive#statusline()}\ Line:%l/%L[%p%%]\ Col:%v\ Buf:#%n\ [%b][0x%B]

" tell VIM to always put a status line in, even if there is only one window
set laststatus=2

" Don't update the display while executing macros
set lazyredraw

set showcmd

" Show the current mode
set showmode

" This is the timeout used while waiting for user input on a multi-keyed macro
" or while just sitting and waiting for another key to be pressed measured
" in milliseconds.
"
" i.e. for the ",d" command, there is a "timeoutlen" wait period between the
"      "," key and the "d" key.  If the "d" key isn't pressed before the
"      timeout expires, one of two things happens: The "," command is executed
"      if there is one (which there isn't) or the command aborts.
set timeoutlen=500

" Keep some stuff in the history
set history=100

" These commands open folds
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo

" When the page starts to scroll, keep the cursor 8 lines from the top and 8
" lines from the bottom
set scrolloff=16

" When completing by tag, show the whole tag, not just the function name
set showfulltag

" Set the textwidth to be 80 chars
set textwidth=80

" get rid of the silly characters in separators
set fillchars=""

" Add ignorance of whitespace to diff
set diffopt+=iwhite

" Add the unnamed register to the clipboard
set clipboard+=unnamed

" Automatically read a file that has changed on disk
set autoread

set grepprg=grep\ -nH\ $*

" Let the syntax highlighting for Java files allow cpp keywords
let java_allow_cpp_keywords = 1

" Toggle paste mode
nmap <silent> ,p :set invpaste<CR>:set paste?<CR>

" The following beast is something i didn't write... it will return the 
" syntax highlighting group that the current "thing" under the cursor
" belongs to -- very useful for figuring out what to change as far as 
" syntax highlighting goes.
nmap <silent> ,qq :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" set text wrapping toggles
nmap <silent> ,ww :set invwrap<CR>:set wrap?<CR>

function! ClearText(type, ...)
	let sel_save = &selection
	let &selection = "inclusive"
	let reg_save = @@
	if a:0 " Invoked from Visual mode, use '< and '> marks
		silent exe "normal! '<" . a:type . "'>r w"
	elseif a:type == 'line'
		silent exe "normal! '[V']r w"
	elseif a:type == 'line'
		silent exe "normal! '[V']r w"
    elseif a:type == 'block'
      silent exe "normal! `[\<C-V>`]r w"
    else
      silent exe "normal! `[v`]r w"
    endif
    let &selection = sel_save
    let @@ = reg_save
endfunction

" Syntax coloring lines that are too long just slows down the world
set synmaxcol=2048

" Highlight the current line and column
" Don't do this - It makes window redraws painfully slow
set nocursorline
set nocursorcolumn

"-----------------------------------------------------------------------------
" Fugitive
"-----------------------------------------------------------------------------
" Thanks to Drew Neil
autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \  noremap <buffer> .. :edit %:h<cr> |
  \ endif
autocmd BufReadPost fugitive://* set bufhidden=delete

nmap ,gs :Gstatus<cr>
nmap ,ge :Gedit<cr>
nmap ,gw :Gwrite<cr>
nmap ,gr :Gread<cr>

"-----------------------------------------------------------------------------
" NERD Tree Plugin Settings
"-----------------------------------------------------------------------------
" Toggle the NERD Tree on an off with F7
nmap <F7> :NERDTreeToggle<CR>

" Show the bookmarks table on startup
let NERDTreeShowBookmarks=1

" Don't display these kinds of files
let NERDTreeIgnore=[ '\.ncb$', '\.suo$', '\.vcproj\.RIMNET', '\.obj$',
                   \ '\.ilk$', '^BuildLog.htm$', '\.pdb$', '\.idb$',
                   \ '\.embed\.manifest$', '\.embed\.manifest.res$',
                   \ '\.intermediate\.manifest$', '^mt.dep$' ]

"-----------------------------------------------------------------------------
" XPTemplate settings
"-----------------------------------------------------------------------------
let g:xptemplate_brace_complete = ''

function! GetParentOfSourceDirectory()
  let fwd = expand('%:p:h')
  let srcparent = substitute(fwd, '/[^/]*/src/.*', '', '')
  return srcparent
endfunction

function! GetProjectRoot(from)
  let dir = split(a:from, "/")
  let found = 0
  while found == 0 && len(dir) != 0
    let tempdir = "/" . join(dir, "/")
    if filereadable(tempdir . "/.fuf.project.root")
      return tempdir
    endif
    let dir = dir[0:-2]
  endwhile
  echoerr "Unable to locate project root (can't find .fuf.project.root file)"
  return ""
endfunction

set wildignore+=*.o,*.class,.git,.svn

"-----------------------------------------------------------------------------
" Autotags Settings
"-----------------------------------------------------------------------------
let g:autotags_no_global = 0
let g:autotags_ctags_opts = "--exclude=target --exclude=vendor"
let g:autotags_ctags_languages = "+Scala,+Java,+Vim"
let g:autotags_ctags_langmap = "Scala:.scala,Java:.java,Vim:.vim,JavaScript:.js"
let g:autotags_ctags_global_include = ""

"-----------------------------------------------------------------------------
" Functions
"-----------------------------------------------------------------------------
if !exists('g:bufferJumpList')
  let g:bufferJumpList = {}
endif

function! MarkBufferInJumpList(bufstr, letter)
  let g:bufferJumpList[a:letter] = a:bufstr
endfunction

function! JumpToBufferInJumpList(letter)
  if has_key(g:bufferJumpList, a:letter)
    exe ":buffer " . g:bufferJumpList[a:letter]
  else
    echoerr a:letter . " isn't mapped to any existing buffer"
  endif
endfunction

function! ListJumpToBuffers()
  for key in keys(g:bufferJumpList)
    echo key . " = " . g:bufferJumpList[key]
  endfor
endfunction

function! IndentToNextBraceInLineAbove()
  :normal 0wk
  :normal "vyf(
  let @v = substitute(@v, '.', ' ', 'g')
  :normal j"vPl
endfunction

function! DiffCurrentFileAgainstAnother(snipoff, replacewith)
  let currentFile = expand('%:p')
  let otherfile = substitute(currentFile, "^" . a:snipoff, a:replacewith, '')
  only
  execute "vertical diffsplit " . otherfile
endfunction

command! -nargs=+ DiffCurrent call DiffCurrentFileAgainstAnother(<f-args>)

function! RunSystemCall(systemcall)
  let output = system(a:systemcall)
  let output = substitute(output, "\n", '', 'g')
  return output
endfunction

function! HighlightAllOfWord(onoff)
  if a:onoff == 1
    :augroup highlight_all
    :au!
    :au CursorMoved * silent! exe printf('match Search /\<%s\>/', expand('<cword>'))
    :augroup END
  else
    :au! highlight_all
    match none /\<%s\>/
  endif
endfunction

:nmap ,ha :call HighlightAllOfWord(1)<cr>
:nmap ,hA :call HighlightAllOfWord(0)<cr>

function! LengthenCWD()
  let cwd = getcwd()
  if cwd == '/'
    return
  endif
  let lengthend = substitute(cwd, '/[^/]*$', '', '')
  if lengthend == ''
    let lengthend = '/'
  endif
  if cwd != lengthend
    exec ":lcd " . lengthend
  endif
endfunction

:nmap ,ld :call LengthenCWD()<cr>

function! ShortenCWD()
  let cwd = split(getcwd(), '/')
  let filedir = split(expand("%:p:h"), '/')
  let i = 0
  let newdir = ""
  while i < len(filedir)
    let newdir = newdir . "/" . filedir[i]
    if len(cwd) == i || filedir[i] != cwd[i]
      break
    endif
    let i = i + 1
  endwhile
  exec ":lcd /" . newdir
endfunction

:nmap ,sd :call ShortenCWD()<cr>

function! RedirToYankRegisterF(cmd, ...)
  let cmd = a:cmd . " " . join(a:000, " ")
  redir @*>
  exe cmd
  redir END
endfunction

command! -complete=command -nargs=+ RedirToYankRegister 
      \ silent! call RedirToYankRegisterF(<f-args>)

function! ToggleMinimap()
  if exists("s:isMini") && s:isMini == 0
    let s:isMini = 1
  else
    let s:isMini = 0
  end

  if (s:isMini == 0)
    " save current visible lines
    let s:firstLine = line("w0")
    let s:lastLine = line("w$")

    " make font small
    exe "set guifont=" . g:small_font
    " highlight lines which were visible
    let s:lines = ""
    for i in range(s:firstLine, s:lastLine)
      let s:lines = s:lines . "\\%" . i . "l"

      if i < s:lastLine
        let s:lines = s:lines . "\\|"
      endif
    endfor

    exe 'match Visible /' . s:lines . '/'
    hi Visible guibg=lightblue guifg=black term=bold
    nmap <s-j> 10j
    nmap <s-k> 10k
  else
    exe "set guifont=" . g:main_font
    hi clear Visible
    nunmap <s-j>
    nunmap <s-k>
  endif
endfunction

command! ToggleMinimap call ToggleMinimap()

