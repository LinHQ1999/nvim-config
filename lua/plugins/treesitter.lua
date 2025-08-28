return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { "BufReadPost", "BufNewFile", "VeryLazy" },
        cmd = { 'TSInstallInfo', 'TSInstall' },
        init = function(plugin)
            -- HACK: https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/treesitter.lua#L21-L29
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        opts = {
            ensurse_installed = {
                "go", "typescript", "tsx", "html", "http", "javascript", "styled", "jsdoc", "json", "vue", "yaml",
                "toml"
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
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ao"] = "@block.outer",
                        ["io"] = "@block.inner",
                        ["av"] = "@assignment.outer",
                        ["iv"] = "@assignment.inner",
                    },
                    selection_modes = {
                        ['@function.outer'] = 'V',
                        ['@block.outer'] = 'V',
                    },
                    include_surrounding_whitespace = true,
                },
            }
        },
        config = function(_, opts)
            -- 高级选项，巨幅提升 parser 下载速度
            -- 要求 curl, tar, 且可以在非 admin 下创建 SymbolicLink
            -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#how-will-the-parser-be-downloaded
            require("nvim-treesitter.install").prefer_git = false

            require("nvim-treesitter.configs").setup(opts)
        end,
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-context',    opts = {} },
            { 'nvim-treesitter/nvim-treesitter-textobjects' }
        }
    },
    {
        'windwp/nvim-ts-autotag',
        ft = { 'vue', 'html', 'typescriptreact', 'javascriptreact', 'xml' },
        opts = {}
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
    },
}
