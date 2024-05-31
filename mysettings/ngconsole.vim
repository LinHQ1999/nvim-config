" 根据打开的目录自动切换主题
function! TrySwitchTheme()
    let s:cwd = getcwd()
    if (stridx(s:cwd, 'oem') != -1)
        colo onelight
    elseif (stridx(s:cwd, 'bug') != -1)
        colo everforest
    else
        colo catppuccin-latte
    endif
endfunction
" au DirChanged * call TrySwitchTheme()
call TrySwitchTheme()
