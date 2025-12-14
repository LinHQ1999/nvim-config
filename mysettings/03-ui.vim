" 配置 colorscheme 和 syntax highlight
" 务必确保 highlight 在 colorscheme 之后进行设置，否则会导致高亮不正确

set termguicolors pumblend=10 winblend=0

" 由于一部分字体设置在 ginit 中死都不生效，所以挪到这里来
if exists('g:goneovim')
    " goneovim 它现在不支持任何字体回退，gfw 会导致字体图标失效
    let &guifont = $NVIM_GUI_FONT
elseif exists('g:neovide')
    " neovide 的字体回退都在 guifont，gfw 不支持
    let &guifont = $NVIM_GUI_FONT

    " 窗口透明 & 输入时隐藏鼠标
    let g:neovide_opacity = has('mac') ? 0.8 : 0.9
    let g:neovide_hide_mouse_when_typing = v:true

    " 减少一点阴影深度
    let g:neovide_floating_shadow = v:true
    let g:neovide_floating_z_height = 2
    let g:neovide_light_angle_degrees = 45
    let g:neovide_light_radius = 1.5

    let g:neovide_remember_window_position = v:true
    let g:neovide_remember_window_size = v:true

    " 滚屏动画配置
    let g:neovide_scroll_animation_length = 0.1
    let g:neovide_scroll_animation_far_lines = 1

    " 输入时动画
    let g:neovide_cursor_animate_in_insert_mode = v:true
    " 跳转到 cmd 时是否使用动画
    let g:neovide_cursor_animate_command_line = v:false

    if has('mac')
        let g:neovide_input_macos_option_key_is_meta = 'both'
        let g:neovide_window_blurred = v:true
    endif
elseif exists('g:gui_vimr')
    let &guifont =  "FantasqueSansM_Nerd_Font_Regular:h18"
    " vimr 既不支持回退列表也不支持 guifontwide
else
    " 借助 gfw 实现 cjk 字符显示，gvim，nvim-qt 通用，
    " 但 nvim-qt 不支持回退列表，分别只能指定一个
    let &guifont = $NVIM_GUI_FONT
    let &guifontwide = $NVIM_GUI_FONT_WIDE
endif

