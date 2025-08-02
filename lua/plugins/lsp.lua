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
                menu = {
                    border = "rounded"
                },
                documentation = {
                    window = {
                        border = "rounded"
                    },
                    auto_show = true
                }
            },
            snippets = { preset = 'luasnip' },
            signature = { enabled = true },
            sources = {
                default = { 'lsp', 'buffer', 'path', 'snippets' },
                providers = {
                    buffer = {
                        opts = {
                            get_bufnrs = function()
                                return vim.tbl_filter(function(bufnr)
                                    return vim.bo[bufnr].buftype == '' or vim.bo[bufnr].buftype == 'help'
                                end, vim.api.nvim_list_bufs())
                            end
                        }
                    }
                }
            },
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" },
    },
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        -- ref: https://github.com/LazyVim/LazyVim/issues/6151#issuecomment-2943642988
        -- ref: https://github.com/LazyVim/LazyVim/pull/6053#issue-3049755158
        -- PERF: 检查是否有更好的解决方案
        event = { "BufReadPre", "BufNewFile", "BufWritePre" },
        dependencies = {
            "saghen/blink.cmp",       -- 确保 vim.lsp.config 在 enable 前
            "williamboman/mason.nvim" -- 必须的 dep，否则未加载时 $MASON 为空 handmade get_mason_path 会失败
        },
        config = function()
            -- 这些东西得写在配置 lsp 服务器前面，即下面的 mason-lspconfig
            require('handmade'):config_lsp(true)

            -- PERF: https://github.com/mason-org/mason-lspconfig.nvim/pull/595
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "yamlls", "vue_ls", "lemminx", "tailwindcss", "lua_ls", "jsonls", "powershell_es", "html", "vtsls",
                    "vimls", "cssls", "eslint", "emmet_language_server", "vimls", "bashls"
                },
            })
        end,
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
        'yioneko/nvim-vtsls',
        ft = { "typescriptreact", "javascriptreact", "typescript", "javascript", "vue", "html" },
        config = function()
            -- 注意，这里是 config 而不是常规的 setup，如果用 opts 则会报错
            -- 另外由于未知原因，指定 cmd lazy 会报错
            require('vtsls').config({
                refactor_auto_rename = true,
            })
        end
    },
    {
        "olexsmir/gopher.nvim",
        ft = { "go", "gomod" },
        build = ":GoInstallDeps",
        opts = {},
    }
}
