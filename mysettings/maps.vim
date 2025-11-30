" leader-key 定义位置见 plugins.lua let mapleader = " "
inoremap fj <Esc> 

" 方便粘贴
inoremap <C-v> <C-r><C-p>+
inoremap <D-v> <C-r><C-p>+

noremap \ :
nnoremap / /\v
nnoremap ? ?\v
noremap <silent> <C-F5> <Cmd>:edit!<CR>
" (cmd mode)
cnoremap <A-b> <C-Left>
cnoremap <A-f> <C-Right>
" (terminal control)
tnoremap fj <C-\><C-n>
tnoremap <Esc> exit<cr>
" (window jump)
noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l
noremap <silent> <A-H> <C-w>H
noremap <silent> <A-J> <C-w>J
noremap <silent> <A-K> <C-w>K
noremap <silent> <A-L> <C-w>L
noremap <silent> <A-w> <C-w>c
" (buffer jump & tab jump)
noremap <silent> <A-t> <Cmd>tabnew<cr>
noremap <silent> <A-W> <Cmd>tabclose<cr>
noremap <silent> <leader><left> <Cmd>bdelete<cr>
" (diff)
noremap <silent> <Leader>dt <Cmd>diffthis<cr>
noremap <silent> <Leader>do <Cmd>diffoff<cr>
" (my)
" or <C-R>=
" 根据最新的 coc 配置，不再使用此项
" inoremap <silent><expr> <tab> CTab()
inoremap <silent><expr> _tm strftime("%Y-%m-%d")
nnoremap <silent> <C-/> <Cmd>.s#\v\\+#/#g<cr>
" 改用 Telescope 吧
"nnoremap <silent> <Leader>fo <Cmd>call Open_fix()<cr>
noremap <silent> <Leader>fc <Cmd>call Compiler()<cr>
noremap <silent> <Leader>fr <Cmd>call Runner()<cr>
nnoremap <silent> <Leader>fs <Cmd>call Set_it()<cr>
nnoremap <silent> <Leader>fd <Cmd>exe "e expand('<sfile>:p:h')"."\pack\my\start\myplugin\plugin\one.vim"<cr>
nnoremap <silent> <Leader>ft <Cmd>call Open_terminal()<cr>
nnoremap <silent> <Leader>fh <Cmd>tcd %:h<cr>
" (fugitive)
" lazygit 快捷键不在此处配置
xnoremap <silent> <Leader>gll :\<C-u>exec "Git log -L ".line("'<").",".line("'>").":% --no-merges --pretty=short"<cr>
nnoremap <silent> <Leader>gls <Cmd>exec expandcmd("Git log -p --no-merges -S<cword> --no-merges --pretty=short")<cr>
" (pluging manager)
nnoremap <silent> <Leader>pi <Cmd>Lazy install<cr>
nnoremap <silent> <Leader>pu <Cmd>Lazy update<cr>
nnoremap <silent> <Leader>pc <Cmd>Lazy clean<cr>
nnoremap <silent> <Leader>pp <Cmd>Lazy profile<cr>
" 2-character Sneak (default)
nmap ' <Plug>Sneak_s
nmap <BS> <Plug>Sneak_S
xmap ' <Plug>Sneak_s
xmap <BS> <Plug>Sneak_S
omap ' <Plug>Sneak_s
omap <BS> <Plug>Sneak_S
