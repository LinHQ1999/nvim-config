return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'BufReadPost',
        cmd = { 'TSInstallInfo', 'TSInstall' },
        config = function(_, opts)
            -- 高级选项，巨幅提升 parser 下载速度
            -- 要求 curl, tar, 且可以在非 admin 下创建 SymbolicLink
            -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#how-will-the-parser-be-downloaded
            require("nvim-treesitter.install").prefer_git = false

            require("nvim-treesitter.configs").setup(opts)
        end,
        opts = {
            ensurse_installed = {
                "c", "lua", "go", "typescript", "tsx", 'markdown', "html", "http", "javascript", "jsdoc", "json", "vue"
            },
            highlight = {
                enable = true
            },
            indent = {
                enable = true,
                disable = {
                    "javascript"
                }
            }
        },
        dependencies = {
            { 'lukas-reineke/indent-blankline.nvim',     main = 'ibl', opts = {} },
            { 'nvim-treesitter/nvim-treesitter-context', opts = {} },
            { 'windwp/nvim-ts-autotag',                  opts = {} }
        }
    },
    {
        'brenoprata10/nvim-highlight-colors',
        ft = { 'vue', 'css', 'less', 'html', 'javascriptreact' },
        opts = {
            render = 'virtual',
            enable_named_colors = false,
            enable_tailwind = false,
            virtual_symbol = '❆ ',
        }
    }
}
