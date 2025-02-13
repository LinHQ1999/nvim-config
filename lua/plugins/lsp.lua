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
            "kevinhwang91/promise-async",
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
        dependencies = { "rafamadriz/friendly-snippets", "saadparwaiz1/cmp_luasnip" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            -- require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "./my_snippets" } })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lsp-signature-help" },
            { "onsails/lspkind.nvim" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local lspkind = require("lspkind")
            local cmp = require("cmp")
            local cmp_action = require('handmade').cmp_helper

            cmp.setup({
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text", -- show only symbol annotations
                        maxwidth = 50,        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        -- can also be a function to dynamically calculate max width such as
                        -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                        ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        show_labelDetails = true,
                    }),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp_action('TAB'),
                    ["<S-Tab>"] = cmp_action('TAB', true),
                    ["<CR>"] = cmp_action('CR'),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4)
                }),
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                sources = {
                    { name = "luasnip" },
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    {
                        name = "buffer",
                        option = {
                            get_bufnrs = function()
                                local bufs = {}
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    local buf = vim.api.nvim_win_get_buf(win)
                                    -- 限制大于 1M 的文件
                                    if
                                        vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                                        <= 1024 * 256
                                    then
                                        bufs[buf] = true
                                    end
                                end
                                return vim.tbl_keys(bufs)
                            end,
                        },
                    },
                    { name = "path" },
                },
                expirment = {
                    ghost_text = true,
                },
            })
        end,
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

            -- :h lspconfig-global-defaults
            -- 这些东西得写在配置 lsp 服务器前面，即下面的 mason-lspconfig
            local builtin = require('lspconfig')
            -- 深拷贝是必要的
            builtin.util.default_config.capabilities = vim.tbl_deep_extend(
                'force',
                builtin.util.default_config.capabilities, -- builitin 是必要的
                require('cmp_nvim_lsp').default_capabilities(),
                {
                    textDocument = {
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true,
                        },
                    }
                }
            )

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
                    if client and client.supports_method('textDocument/inlayHint') then
                        vim.lsp.inlay_hint.enable(true)
                    end
                    local map = vim.keymap.set
                    map("n", "<up>", vim.diagnostic.goto_prev, opts)
                    map("n", "<down>", vim.diagnostic.goto_next, opts)
                    map('n', 'gd', vim.lsp.buf.definition, opts)
                    map('n', 'gD', vim.lsp.buf.declaration, opts)
                    map('n', 'gi', vim.lsp.buf.implementation, opts)
                    map("n", "gh", vim.lsp.buf.hover, opts)
                    map('n', 'gs', vim.lsp.buf.signature_help, opts)
                    map('n', '<F2>', vim.lsp.buf.rename, opts)
                    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    map("n", "<leader>cf", vim.lsp.buf.format, opts)
                end
            })

            require('handmade').init_lsp()
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
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>xv",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        }
    },
    {
        'nvim-flutter/flutter-tools.nvim',
        ft = "dart",
        dependencies = {
            'nvim-lua/plenary.nvim',
            'stevearc/dressing.nvim'
        },
        opts = {},
    }
}
