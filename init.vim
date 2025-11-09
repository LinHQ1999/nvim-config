"lua/plugins.lua
"mysettings/functions.vim
"mysettings/basic.vim
"mysettings/ui.vim
"mysettings/maps.vim
"mysettings/autocmds.vim
" ----------------gf 快速跳转通道----------------

lua << EOF
local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)
require('lazy').setup('plugins')
EOF

let s:transform = {dir, list -> join(map(list,  { _, module -> dir."/".module.".vim" }), ' ')}

" ui 必须在 plugins 后，原因：colorscheme 需要 theme 先加载
" firenvim 必须在最后，覆盖所有的设置
let s:dir = 'mysettings'
let s:modules = [ "functions", "basic", "ui", "maps", "autocmds"]

" 这里假定加载按照列表顺序，否则应该用链式加载确保顺序
exec "runtime! ".s:transform(s:dir, s:modules)

