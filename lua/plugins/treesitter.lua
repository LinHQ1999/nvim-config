return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { "BufReadPost", "BufNewFile" },
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
                "go", "typescript", "tsx", "html", "http", "javascript", "jsdoc", "json", "vue"
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
                        ["ac"] = "@class.outer",
                        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                        ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                    },
                    selection_modes = {
                        ['@parameter.outer'] = 'v', -- charwise
                        ['@function.outer'] = 'V',  -- linewise
                        ['@class.outer'] = '<c-v>', -- blockwise
                    },
                    include_surrounding_whitespace = true,
                },
            },
        },
        dependencies = {
            { 'lukas-reineke/indent-blankline.nvim',        main = 'ibl', opts = {} },
            { 'nvim-treesitter/nvim-treesitter-context',    opts = {} },
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
            { 'windwp/nvim-ts-autotag',                     opts = {} },
        }
    },
    {
        'brenoprata10/nvim-highlight-colors',
        ft = { 'vue', 'css', 'less', 'html', 'typescriptreact', 'javascriptreact' },
        opts = {
            render = 'virtual',
            enable_named_colors = false,
            enable_tailwind = false,
            virtual_symbol = '❆ ',
        }
    }
}
