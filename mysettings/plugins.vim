call plug#begin(stdpath('data').'\plugins')
    " 对接外部库
    Plug 'tpope/vim-fugitive'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'NTBBloodbath/rest.nvim'
    Plug 'gpanders/editorconfig.nvim'
    " IDE 支持
    Plug 'williamboman/mason.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'folke/trouble.nvim'
    Plug 'folke/neodev.nvim'
    Plug 'creativenull/efmls-configs-nvim', { 'tag': 'v1.*' }
    " 补全插件
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/cmp-calc'
    Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'mingw32-make install_jsregexp'}
    Plug 'hrsh7th/nvim-cmp'
    Plug 'onsails/lspkind.nvim'
    "临时使用
    Plug 'simrat39/symbols-outline.nvim'
    Plug 'mattn/emmet-vim', {'for': ['javascript', 'html', 'javascriptreact', 'typescriptreact', 'vue']}
    Plug 'fatih/vim-go', {'for': 'go'}
    Plug 'nvim-orgmode/orgmode',
    Plug 'akinsho/org-bullets.nvim'
    " 编辑体验增强
    Plug 'm4xshen/autoclose.nvim'
    Plug 'windwp/nvim-ts-autotag'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'tpope/vim-surround'
    Plug 'numToStr/Comment.nvim'
    Plug 'tpope/vim-repeat'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
    " 主题
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'sainnhe/forest-night'
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'olimorris/onedarkpro.nvim'
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    " 语法高亮和语言插件
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'frozen': v:true}
call plug#end()

" (vista)
let g:vista_cursor_delay = 60
let g:vista_sidebar_position = "vertical botright"
let g:vista_default_executive = "coc"

" (lsp)
"set updatetime=500
set shortmess+=c
set signcolumn=number

" (vim-plug)
let g:plug_timeout = 180
let g:plug_retries = 5

" (vim-go)
let g:go_term_mode = "split"
let g:go_term_enabled = 1
" 使用 coc-go 代替
let g:go_code_completion_enabled = v:false
let g:go_gopls_enabled = v:true
let g:go_imports_autosave = v:true
let g:go_mod_fmt_autosave = v:false
let g:go_metalinter_autosave = v:false

" (rust)
let g:rustfmt_autosave = 1

" (vimwiki)
" let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md', 'auto_tags': 1}]
" let g:mkdp_auto_start = 0

" (finder)
let g:clap_enable_icon = v:true
let g:clap_provider_grep_opts = '-H --no-heading --vimgrep --smart-case --hidden -g "!.git/"'
let g:clap_search_box_border_symbols = { 'triangle': [ "\ue0ba", "\ue0b8" ] }
let g:clap_search_box_border_style = 'triangle'
let g:clap_popup_border = "double"
let g:clap_layout = { 'relative': 'editor' }
let g:clap_forerunner_status_sign = { 'running': '', 'done': '', 'using_cache': '' }
let g:clap_prompt_format = ' %spinner% %provider_id% %forerunner_status% > '

" lua 插件也需要在 plugins 后
lua require('plugins')
