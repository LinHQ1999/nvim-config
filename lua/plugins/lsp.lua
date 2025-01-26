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
        "VonHeikemen/lsp-zero.nvim",
        branch = "v4.x",
        lazy = true, -- 由 require 自动调用
        config = false
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
            local cmp_action = require('lsp-zero').cmp_action() --Tab 自动完成之类的

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
                    ["<Tab>"] = cmp_action.luasnip_supertab(), --[[ cmp_action 来自 lsp_zero ]]
                    ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-j>"] = cmp_action.luasnip_jump_forward(),
                    ["<C-k>"] = cmp_action.luasnip_jump_backward(),
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
                    { name = "nvim_lsp" },
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
                    { name = "nvim_lsp_signature_help" },
                    { name = "luasnip" },
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
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim"
        },
        config = function()
            -- 一个简单的工具函数
            local registry = require("mason-registry")
            local get_mason_path = function(package)
                return registry.get_package(package):get_install_path()
            end

            vim.api.nvim_create_autocmd('BufWritePre', {
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

            -- 注意：这里不能放到上面 mason-lspconfig 的懒加载配置中，会导致监听在 server attach 之后，从而无法触发
            --- if you want to know more about lsp-zero and mason.nvim
            --- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
            -- 这里仅仅是 lsp 可用就加载相应的快捷键，而不是直接全局设置
            local lsp_zero = require("lsp-zero")

            -- 必须在设置各种 lsp 之前调用，所以放这里
            lsp_zero.extend_lspconfig({
                sign_text = true,
                capabilities = vim.tbl_deep_extend('force',
                    require('cmp_nvim_lsp').default_capabilities(),
                    {
                        textDocument = {
                            foldingRange = {
                                dynamicRegistration = false,
                                lineFoldingOnly = true,
                            },
                        }
                    }),
                lsp_attach = function(_, bufnr)
                    -- see :help lsp-zero-keybindings
                    -- to learn the available actions
                    lsp_zero.default_keymaps({ buffer = bufnr })
                    local opts = { silent = true, buffer = bufnr }
                    vim.keymap.set("n", "<up>", function() vim.diagnostic.goto_next() end, opts)
                    vim.keymap.set("n", "<down>", function() vim.diagnostic.goto_prev() end, opts)
                    vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, opts)
                end
            })

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "yamlls",
                    "volar",
                    "lemminx",
                    "tailwindcss",
                    "lua_ls",
                    "jsonls",
                    "powershell_es",
                    "html",
                    "vtsls",
                    "vimls",
                    "cssls",
                    "eslint",
                    "emmet_language_server",
                    "vimls",
                    "bashls"
                },
                -- 启用 lsp 自动配置
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({})
                    end,

                    -- 覆盖 lua
                    lua_ls = function()
                        -- 对 neovim lua 配置特别优化的 opt
                        require("lspconfig").lua_ls.setup(lsp_zero.nvim_lua_ls())
                    end,
                    powershell_es = function()
                        require("lspconfig").powershell_es.setup({
                            bundle_path = get_mason_path("powershell-editor-services"),
                        })
                    end,
                    vtsls = function()
                        -- 考虑安装 nvim-vtsls 插件
                        require("lspconfig")["vtsls"].setup({
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
                "<leader>xX",
                "<cmd>Trouble todo<cr>",
                desc = "Show todo in trouble",
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
        },
        dependencies = {
            "folke/todo-comments.nvim"
        }
    },
    {
        'nvim-flutter/flutter-tools.nvim',
        ft = "dart",
        dependencies = {
            'nvim-lua/plenary.nvim',
            'stevearc/dressing.nvim'
        },
    }
}
