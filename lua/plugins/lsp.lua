--[[ 必须保证的顺序：
    1. mason
    2. mason-lspconfig
    3. lspconfig ]]

return {
    {
        "kevinhwang91/nvim-ufo",
        event = "VeryLazy", -- 不能为 BufReadPre，见  https://github.com/kevinhwang91/nvim-ufo/issues/47#issuecomment-1248773096
        config = function()
            local ufo = require("ufo")

            vim.o.foldcolumn = "0"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            vim.keymap.set("n", "zR", ufo.openAllFolds)
            vim.keymap.set("n", "zM", ufo.closeAllFolds)

            ufo.setup()
        end,
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
        dependencies = { "williamboman/mason.nvim" },
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
            -- require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "./my_snippets" } })
        end,
    },
    {
        'saghen/blink.cmp',
        event = "InsertEnter",

        -- use a release tag to download pre-built binaries
        version = '1.*',

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
            },
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    },
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim"
        },
        config = function()
            -- 这些东西得写在配置 lsp 服务器前面，即下面的 mason-lspconfig
            require('handmade'):config_lsp()

            local lsp_group = vim.api.nvim_create_augroup("LSP", {})
            local lsp_group_rpt = vim.api.nvim_create_augroup("LSP.NOCLEAR", { clear = false })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_group,
                callback = function(e)
                    -- :h lsp-config
                    local client, opts = vim.lsp.get_client_by_id(e.data.client_id), { silent = true, buffer = e.buf }
                    if not client then return end
                    -- :h lsp-inlay_hint
                    -- :h lsp-method
                    -- :h lsp-client
                    if client:supports_method('textDocument/inlayHint') then
                        vim.lsp.inlay_hint.enable(true)
                    end

                    -- eslint 不支持格式化，但提供一个 LspEslintFixAll 来实现类似的效果
                    if client:supports_method('textDocument/formatting') or client.name == 'eslint' then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = e.buf,
                            group = lsp_group_rpt,
                            callback = function()
                                -- 这里允许多次注册，小心不要重复
                                -- 同样，也不要调用异步的格式化方法
                                if client.name == 'eslint' then
                                    vim.cmd([[LspEslintFixAll]])
                                else
                                    vim.lsp.buf.format({
                                        bufnr = e.buf,
                                        id = client.id,
                                        timeout_ms = 900
                                    })
                                end
                            end
                        })
                    end

                    local map = vim.keymap.set
                    map("n", "<up>", function() vim.diagnostic.jump({ float = true, count = -1 }) end, opts)
                    map("n", "<down>", function() vim.diagnostic.jump({ float = true, count = 1 }) end, opts)
                    map('n', 'gd', [[<Cmd>Telescope lsp_definitions<CR>]], opts)
                    map('n', 'gr', [[<Cmd>Telescope lsp_references<CR>]], opts)
                    map('n', 'gD', vim.lsp.buf.declaration, opts)
                    map('n', 'gi', [[<Cmd>Telescope lsp_implementions<CR>]], opts)
                    map("n", "gh", function() vim.lsp.buf.hover({ border = 'rounded' }) end, opts)
                    map('n', 'gs', function() vim.lsp.buf.signature_help({ border = 'rounded' }) end, opts)
                    map('n', '<F2>', vim.lsp.buf.rename, opts)
                    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    map("n", "<leader>cf", vim.lsp.buf.format, opts)

                    -- 调用 vtsls 专用方法
                    if client.name == 'vtsls' then
                        map("n", "<leader>ci", [[<Cmd>VtsExec organize_imports<cr>]], opts)
                        map("n", "<leader>cm", [[<Cmd>VtsExec add_missing_imports<cr>]], opts)
                    end
                end
            })

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
        opts = {
            -- automatically trigger renaming of extracted symbol
            refactor_auto_rename = true,
            refactor_move_to_file = {
                -- If dressing.nvim is installed, telescope will be used for selection prompt. Use this to customize
                -- the opts for telescope picker.
                telescope_opts = function(items, default) end,
            }
        }
    }
}
