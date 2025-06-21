return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { "BufReadPost", "BufNewFile", "VeryLazy" },
        cmd = { 'TSInstallInfo', 'TSInstall' },
        init = function(plugin)
            -- 抄一抄，某种 workaround
            -- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/treesitter.lua#L21-L29
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        config = function(_, opts)
            -- 高级选项，巨幅提升 parser 下载速度
            -- 要求 curl, tar, 且可以在非 admin 下创建 SymbolicLink
            -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#how-will-the-parser-be-downloaded
            require("nvim-treesitter.install").prefer_git = false

            require("nvim-treesitter.configs").setup(opts)
        end,
        opts = {
            ensurse_installed = {
                "go", "typescript", "tsx", "html", "http", "javascript", "styled", "jsdoc", "json", "vue", "yaml", "toml"
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "autohotkey" },
            },
            indent = {
                enable = true,
                disable = {
                    "javascript"
                }
            }
        },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-context', opts = {} },
            { 'windwp/nvim-ts-autotag',                  opts = {} },
        }
    },
    {
        'brenoprata10/nvim-highlight-colors',
        ft = { 'vue', 'css', 'less', 'html', 'typescriptreact', 'javascriptreact', 'dart' },
        opts = {
            render = 'virtual',
            enable_named_colors = false,
            enable_tailwind = false,
            virtual_symbol = '❆ ',
        }
    }
}
