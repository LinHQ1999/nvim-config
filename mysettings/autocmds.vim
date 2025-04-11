augroup RC
    autocmd!
    " 官方文档推荐
    autocmd TermOpen * startinsert
    autocmd TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
    " 调整窗口自动对齐布局
    autocmd VimResized * wincmd =
    autocmd FileType powershell setl smartindent
    " smartindent 看上去和 coc-pairs 冲突
    autocmd BufRead *.ps1 set nosmartindent
    autocmd FileType javascript,vue,scss,less,typescriptreact,javascriptreact,org,json,typescript,dart setl softtabstop=2 | setl shiftwidth=2
    " (vimwiki)
    " 自动更新日记索引
    autocmd BufWinEnter diary.md execute "VimwikiDiaryGenerateLinks" | w
    autocmd FileType vimwiki,markdown,text,tex set wrap
augroup END

" 因为包括了 FocusGained，所以需要判断 mode()
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | setl rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | setl nornu | endif
augroup END

" neovide 可以自动进行输入法切换，但搜索时也无法输入中文，先禁用
" if exists('g:neovide') 
"     augroup ime_input
"         autocmd! 
"         autocmd InsertLeave * execute "let g:neovide_input_ime=v:false"
"         autocmd InsertEnter * execute "let g:neovide_input_ime=v:true"
"         autocmd CmdlineEnter [/\?] execute "let g:neovide_input_ime=v:false"
"         autocmd CmdlineLeave [/\?] execute "let g:neovide_input_ime=v:true"
"     augroup END
" endif

" 添加一些文件类型别名
" 注意，这里和 treesitter 的类型别名不一样，但效果应该差不多:
" https://github.com/nvim-treesitter/nvim-treesitter/blob/master/README.md#using-an-existing-parser-for-another-filetype
lua << EOF
local alias = {
    wxml = "vue",
    wxss = "css",
    less = "scss",
    arb = "json"
}

vim.filetype.add ({
    extension = alias
})
EOF
