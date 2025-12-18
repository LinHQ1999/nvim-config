--[[ 必须保证的顺序：
    1. mason
    2. mason-lspconfig
    3. lspconfig ]]

return {
    {
        "kevinhwang91/nvim-ufo",
        event = "VeryLazy", -- 不能为 BufReadPre，见  https://github.com/kevinhwang91/nvim-ufo/issues/47#issuecomment-1248773096
        keys = {
            { "zR", function() require('ufo').openAllFolds() end, desc = "开启所有 fold" },
            { "zM", function() require('ufo').closeAllFolds() end, desc = "关闭所有 fold" },
        },
        init = function()
            vim.o.foldcolumn = "0"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
        end,
        opts = {
            provider_selector = function(_, ft)
                -- NOTE: git 类型直接启用 syntax 折叠好看文件名，关闭 ufo 不然是 indent 模式
                if ft == 'git' then
                    return ''
                end
            end
        },
        dependencies = {
            { "kevinhwang91/promise-async" },
        },
    },
    {
        "williamboman/mason.nvim",
        cmd = { "MasonUpdate", "Mason" },
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = true
    },
    {
        "L3MON4D3/LuaSnip",
        lazy = true,
        version = "2.*",
        build = "make install_jsregexp",
        dependencies = {
            { "rafamadriz/friendly-snippets" },
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "./my_snippets" } })
        end,
    },
    {
        'saghen/blink.cmp',

        -- use a release tag to download pre-built binaries
        version = '1.*',
        lazy = true,
        ---@type blink.cmp.Config
        opts = {
            keymap = { preset = 'enter' },
            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'normal'
            },
            completion = {
                ghost_text = {
                    enabled = true,
                },
                documentation = {
                    auto_show = true
                }
            },
            snippets = { preset = 'luasnip' },
            signature = { enabled = true },
            sources = {
                default = { 'lsp', 'buffer', 'path', 'snippets' },
                providers = {
                    lsp = {
                        fallbacks = {} -- 同时显示 lsp 和 buffer 补全
                    },
                    buffer = {
                        opts = {
                            get_bufnrs = function()
                                return vim.tbl_filter(function(bufnr)
                                    return vim.bo[bufnr].buftype == '' or vim.bo[bufnr].buftype == 'help'
                                end, vim.api.nvim_list_bufs())
                            end
                        }
                    }
                },
                per_filetype = {
                    codecompanion = { "codecompanion" }
                },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" },
    },
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            "saghen/blink.cmp",       -- Blink 自动更新 capability 但需要在 lsp 启动前，https://github.com/LazyVim/LazyVim/issues/5405#issuecomment-2593284102
            "williamboman/mason.nvim" -- 必须的 dep，否则未加载时 $MASON 为空 handmade get_mason_path 会失败
        },
        -- NOTE: 采用 folk 的 方案（相比 BufReadPre）
        -- REF: https://github.com/LazyVim/LazyVim/issues/6456#issuecomment-3307108576
        -- REF: https://github.com/LazyVim/LazyVim/commit/75a3809e15a0ecff9adc46c6cd3aaac51d99b561#diff-a0920a251d78a12e9598cacc20f73324759a994fd02d07823ebb34ab019f26e3R121
        config = vim.schedule_wrap(function()
            -- 这些东西得写在配置 lsp 服务器前面，即下面的 mason-lspconfig
            require('handmade'):config_lsp(true)

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "yamlls", "vue_ls", "lemminx", "tailwindcss", "lua_ls", "jsonls", "powershell_es", "html", "tsgo",
                    "vimls", "cssls", "bashls", "eslint"
                },
            })
        end),
    },
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = { "Trouble" },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)", },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics (Trouble)", },
            { "<leader>xv", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)", },
            { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)", },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List (Trouble)", },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List (Trouble)", },
        }
    },
    {
        'nvim-flutter/flutter-tools.nvim',
        ft = { "dart" },
        opts = {},
    },
    {
        "olexsmir/gopher.nvim",
        ft = { "go", "gomod" },
        build = ":GoInstallDeps",
        opts = {},
    }
}
