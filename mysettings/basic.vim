" `:options` for all available options.
filetype plugin indent on
packadd matchit
packadd cfilter
packadd nohlsearch
" NOTE: https://github.com/nvim-treesitter/nvim-treesitter/issues/5896#issuecomment-1910818227
" syntax enable
set title
set grepprg=rg\ --vimgrep
"set mouse=i
"set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312
set cursorline cursorcolumn
" set showmatch
set matchpairs+=<:>
set number relativenumber
"set autoindent
"set smartindent
" 负数自动和 shiftwidth 取一样的值
set shiftwidth=4 softtabstop=-1 expandtab
set timeoutlen=1500
set splitbelow splitright
set ignorecase
"set hidden
set cmdheight=1
set nobackup
"set nowritebackup
set foldopen-=search
" set nowrap
set showbreak=\|>\ 
set wildoptions+=fuzzy
set diffopt+=vertical,linematch:60,algorithm:histogram
set jumpoptions+=stack
" set winborder=rounded " 暂时插件支持不好
set undofile
set scrolloff=8
set switchbuf=usetab,vsplit

if has('win32') || has('win64') || &shell =~ 'pwsh'
    let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
    let &shellcmdflag = '-NoProfile -NoProfileLoadTime -NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
    let &shellredir = '2>&1 | foreach { "$_" } | Out-File %s; exit $LastExitCode'
    let &shellpipe  = '2>&1 | foreach { "$_" } | tee %s; exit $LastExitCode'
    set shellquote= shellxquote=
endif
