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
            -- 一个简单的工具函数
            local get_mason_path = function(package)
                return vim.fs.joinpath(vim.env.MASON, 'packages', package)
            end

            -- 这些东西得写在配置 lsp 服务器前面，即下面的 mason-lspconfig
            local hm = require('handmade')
            hm.add_lsp()
            hm.override_lsp()

            local lsp_group = vim.api.nvim_create_augroup("LSP", { clear = true })

            vim.api.nvim_create_autocmd('BufWritePre', {
                group = lsp_group,
                callback = function(event)
                    local eslint = vim.lsp.get_clients({ name = 'eslint', bufnr = event.buf })

                    if vim.tbl_isempty(eslint) then
                        -- vim.lsp.buf.format()
                    else
                        vim.cmd("EslintFixAll")
                        vim.cmd("w")
                    end
                end
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_group,
                callback = function(e)
                    -- :h lsp-config
                    local client, opts = vim.lsp.get_client_by_id(e.data.client_id), { silent = true, buffer = e.buf }
                    -- :h lsp-inlay_hint
                    -- :h lsp-method
                    -- :h lsp-client
                    if client and client:supports_method('textDocument/inlayHint') then
                        vim.lsp.inlay_hint.enable(true)
                    end
                    local map = vim.keymap.set
                    map("n", "<up>", function() vim.diagnostic.jump({ float = true, count = -1 }) end, opts)
                    map("n", "<down>", function() vim.diagnostic.jump({ float = true, count = 1 }) end, opts)
                    map('n', 'gd', '<Cmd>Telescope lsp_definitions<CR>', opts)
                    map('n', 'gr', '<Cmd>Telescope lsp_references<CR>', opts)
                    map('n', 'gD', vim.lsp.buf.declaration, opts)
                    map('n', 'gi', '<Cmd>Telescope lsp_implementions<CR>', opts)
                    map("n", "gh", function() vim.lsp.buf.hover({ border = 'rounded' }) end, opts)
                    map('n', 'gs', function() vim.lsp.buf.signature_help({ border = 'rounded' }) end, opts)
                    map('n', '<F2>', vim.lsp.buf.rename, opts)
                    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    map("n", "<leader>cf", vim.lsp.buf.format, opts)
                end
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "yamlls", "volar", "lemminx", "tailwindcss", "lua_ls", "jsonls", "powershell_es", "html", "vtsls",
                    "vimls", "cssls", "eslint", "emmet_language_server", "vimls", "bashls"
                },
                -- 启用 lsp 自动配置
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({})
                    end,

                    -- lua_ls 根据配置根目录的 luarc.json 自动配置
                    -- https://luals.github.io/wiki/configuration/#configuration-file

                    powershell_es = function()
                        require("lspconfig").powershell_es.setup({
                            bundle_path = get_mason_path("powershell-editor-services"),
                        })
                    end,
                    vtsls = function()
                        -- 考虑安装 nvim-vtsls 插件
                        require("lspconfig").vtsls.setup({
                            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
                            settings = {
                                vtsls = {
                                    tsserver = {
                                        globalPlugins = {
                                            {
                                                name = "@vue/typescript-plugin",
                                                location = vim.fs.joinpath(
                                                    get_mason_path("vue-language-server"),
                                                    "node_modules",
                                                    "@vue",
                                                    "language-server"
                                                ),
                                                languages = { "vue" },
                                                configNamespace = "typescript",
                                                enableForWorkspaceTypeScriptVersions = true,
                                            },
                                        },
                                    },
                                    expirmental = {
                                        completion = {
                                            enableServerSideFuzzyMatch = true
                                        }
                                    }
                                },
                            },
                        })
                    end,
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
        ft = "dart",
        opts = {},
    }
}
