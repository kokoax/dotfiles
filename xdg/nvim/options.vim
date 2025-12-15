" マウス操作の無効化
set mouse=
set clipboard+=unnamedplus

set fileformats=unix,dos,mac
set encoding=utf-8
set fileencodings=utf-8,sjis,euc-jp,iso-2022-jp
set fileencoding=utf-8

set textwidth=0

set smartindent
set expandtab

set autoindent
"HTML特有のインデントを切る.
autocmd FileType html :setlocal indentexpr=''

" syntax highlight で読み込む最大の行数
set synmaxcol=200

set display=lastline

set pumheight=10

set showmatch
set matchtime=1

set tabstop=2
set shiftwidth=2
set softtabstop=2

set nocompatible
" set guioptions+=a

" set nofoldenable
set foldmethod=syntax

" tagsファイルの指定
set tags=./tags,./TAGS,tags,TAGS,.tags

" 閉じカッコが入力されたら,対応するカッコをハイライトする
set showmatch

" 選択しいる行をしばらく時間が立つとハイライト
set cursorline

autocmd BufNewFile, BufRead *.php setf html

" 全部インデントしてカーソルを元のの位置に戻す
function All_indent()
  let view = winsaveview()
  normal gg=G''
  silent call winrestview(view)
endfunction
" autocmd BufWritePre * :call All_indent()

" リポジトリ下に.vimrc.localを配置すると読み込んでくれるように設定
augroup vimrc-local
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:vimrc_local(expand('<afile>:p:h'))
augroup END

function! s:vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction
