" lsp 相关的快捷键都挪到 ide.lua 里面去了
let mapleader = " "
inoremap fj <Esc> 

" 方便粘贴
nnoremap <A-S-v> "+p
" 原 Ctrl-v 建议使用 Ctrl-Q
inoremap <C-v> <C-o>"+P
vnoremap <C-c> "+y

noremap \ :
nnoremap / /\v
nnoremap ? ?\v
nnoremap <silent> <leader>n <Cmd>noh<CR>
" (terminal control)
tnoremap fj <C-\><C-n>
tnoremap <Esc> exit<cr>
" (window jump)
noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l
noremap <silent> <A-S-h> <C-w>H
noremap <silent> <A-S-j> <C-w>J
noremap <silent> <A-S-k> <C-w>K
noremap <silent> <A-S-l> <C-w>L
" (buffer jump & tab jump)
noremap <silent> <C-Left> <Cmd>bp<cr>
noremap <silent> <C-Right> <Cmd>bn<cr>
noremap <silent> <C-S-Up> <Cmd>tabnew<cr>
noremap <silent> <C-S-Down> <Cmd>tabclose<cr>
noremap <silent> <leader><left> <Cmd>bdelete<cr>
" (my)
" or <C-R>=
" 根据最新的 coc 配置，不再使用此项
" inoremap <silent><expr> <tab> CTab()
inoremap <silent><expr> _tm strftime("%Y-%m-%d")
" 改用 Telescope 吧
"nnoremap <silent> <Leader>fo <Cmd>call Open_fix()<cr>
noremap <silent> <Leader>fc <Cmd>call Compiler()<cr>
noremap <silent> <Leader>fr <Cmd>call Runner()<cr>
nnoremap <silent> <Leader>fs <Cmd>call Set_it()<cr>
nnoremap <silent> <Leader>ft <Cmd>call Open_terminal()<cr>
nnoremap <silent> <Leader>fh <Cmd>tcd %:h<cr>
" (single plugin maps)
nnoremap <silent> <Leader>pv <Cmd>SymbolsOutline<cr>
" (tree)
nnoremap <silent> <Leader>pd <Cmd>NvimTreeFindFileToggle<cr>
" (fugitive)
nnoremap <silent> <Leader>gs <Cmd>G<cr>
nnoremap <silent> <Leader>gps <Cmd>Git push<cr>
nnoremap <silent> <Leader>gpl <Cmd>Git pull<cr>
nnoremap <silent> <Leader>gla <Cmd>Gclog<cr>
nnoremap <silent> <Leader>gll <Cmd>exec "Git log -L ".line('.').",".line('.').":% --no-merges"<cr>
nnoremap <silent> <Leader>gls :Git log -p --no-merges -S"<cword>" %<cr>
" (gitsigns)
nnoremap <silent> ]g <Cmd>Gitsigns next_hunk<cr>
nnoremap <silent> [g <Cmd>Gitsigns prev_hunk<cr>
" (vim-plug)
nnoremap <silent> <Leader>pi <Cmd>PlugInstall<cr>
nnoremap <silent> <Leader>pu <Cmd>PlugUpdate<cr>
nnoremap <silent> <Leader>pc <Cmd>PlugClean<cr>
nnoremap gx <Cmd>exec "!start ".expand('<cfile>')<cr>
" (finder)
noremap <silent> <Leader>lf <Cmd>Telescope find_files<CR>
noremap <silent><Leader>lg <Cmd>Telescope live_grep<CR>
noremap <silent> <Leader>lb <Cmd>Telescope buffers<CR>
noremap <silent> <Leader>lr <Cmd>Telescope oldfiles<CR>
noremap <silent> <Leader>lv <Cmd>Telescope vim_options<CR>
noremap <silent> <Leader>ll <Cmd>Telescope current_buffer_fuzzy_find<CR>
