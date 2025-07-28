" Caclulator, you can also use winheight() and winwidth()
let g:Sp_height = {x -> float2nr(nvim_win_get_height(0) * x)}
let g:Vsp_width = {x -> float2nr(nvim_win_get_width(0) * x)}

" Tab to complete
function! Check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Function to get current absolute file path, also see fnamemodify()
function! Get_current_path(...)
    if a:0 == 0
        return expand("%:p")
    elseif a:0 > 1
        echom "Wrong argument"
    else
        return expand("%".a:1)
    endif
endf

" Split window in percent.
function! PercentSplit(percent, action)
    if a:action == "sp"
        let l:temp = g:Sp_height(a:percent)
    else
        let l:temp = g:Vsp_width(a:percent)
    endif
    " [N]sp/vsp
    exe l:temp.a:action
endf

function! Compiler()
    exe "wa"
    call PercentSplit(0.4, "sp")
    if &filetype=='c'
        exe "te clang -o %:r.exe %"
    elseif &filetype=='cpp'
        exe "te g++ -o %:r.exe %"
    elseif &filetype=='java'
        exe "te javac -encoding utf-8 %"
    elseif &filetype=='go'
        exe "go build"
    else 
        echo 'Do not support this type of file!'
        exe "q"
    endif
endf

function! Runner()
    write
    if &filetype == 'html'
        exe "!%"
    elseif &filetype == 'go'
        exe ":GoRun %"
    else
        call PercentSplit(0.4, "sp")
        if &filetype=='cpp'|| &filetype=='c'
            exe "te %:r.exe"
        elseif &filetype == 'javascript'
            exe "te node %"
        elseif &filetype == 'java'
            exe "te java %:r"
        elseif &filetype == 'typescript'
            exe "te node %<.js"
        elseif &filetype == 'rust'
            exe "te cargo run"
        elseif &filetype == 'python'
            exe "te python %"
        elseif &filetype == 'ps1'
            exe "te powershell -c \"./%\""
        else
            quit
        endif
    endif
endf

" Neovim 专属
function! Set_it()
    exe g:Sp_height(0.8)."sp ".stdpath("config")."/init.vim"
    exe "lcd %:h"
endf

let s:cwd = fnamemodify("<sfile>", ":p:h")
function! Go_plugin()
    exe "NERDTreeToggle ".s:cwd."/pack/my/start"
endf

function! Open_terminal()
    call PercentSplit(0.4, "sp")
    exe "te"
endf

" 打开 quickfix 或者 locallist
function! Open_fix()
    if len(getqflist())
        copen
    elseif len(getloclist(0)) 
        lopen
    else
        echo 'Neither quickfix or locallist has any sources!'
    endif
endfunction
