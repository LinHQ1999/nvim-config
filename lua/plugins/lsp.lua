--[[ 必须保证的顺序：
    1. mason
    2. mason-lspconfig
    3. lspconfig ]]

return {
    {
        'kevinhwang91/nvim-ufo',
        lazy = true,
        opts = {},
        config = function(_, opts)
            local ufo = require('ufo')

            ufo.setup(opts)

            vim.o.foldcolumn = '0'
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            vim.keymap.set('n', 'zR', ufo.openAllFolds)
            vim.keymap.set('n', 'zM', ufo.closeAllFolds)
        end,
        dependencies = {
            { 'kevinhwang91/promise-async' }
        }
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = {},
        init = function()
            -- Disable automatic setup, we are doing it manually
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },
    {
        'L3MON4D3/LuaSnip',
        lazy = true,
        dependencies = { 'rafamadriz/friendly-snippets' },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load({ path = { "./my_snippets" } })
        end
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            { 'onsails/lspkind.nvim' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            'L3MON4D3/LuaSnip',
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            local lspkind = require('lspkind')
            local cmp = require('cmp')
            local cmp_action = lsp_zero.cmp_action() --Tab 自动完成之类的

            lsp_zero.extend_cmp()

            cmp.setup({
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol_text', -- show only symbol annotations
                        maxwidth = 50,        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        -- can also be a function to dynamically calculate max width such as
                        -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        show_labelDetails = true
                    })
                },
                mapping = cmp.mapping.preset.insert({
                    ['<Tab>'] = cmp_action.luasnip_supertab(),
                    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
                }),
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" }
                }
            })
        end
    },
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = true,
        config = function()
            local lsp_zero = require('lsp-zero')

            -- 必须在设置各种 lsp 之前调用，所以放这里
            lsp_zero.extend_lspconfig()
            require('mason-lspconfig').setup({
                ensure_installed = {},
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,

                    -- this is the "custom handler" for `lua_ls`
                    lua_ls = function()
                        -- (Optional) Configure lua language server for neovim
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                }
            })

            -- 用于配置 ufo lsp 折叠
            lsp_zero.set_server_config({
                capabilities = {
                    textDocument = {
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true
                        }
                    }
                }
            })
        end
    },
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            'kevinhwang91/nvim-ufo',
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' }
        },
        config = function()
            -- This is where all the LSP shenanigans will live
            local lsp_zero = require('lsp-zero')

            --- if you want to know more about lsp-zero and mason.nvim
            --- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
            -- 这里仅仅是 lsp 可用就加载相应的快捷键，而不是直接全局设置
            lsp_zero.on_attach(function(_, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })
                vim.keymap.set('n', '<up>', vim.diagnostic.goto_prev, { silent = true })
                vim.keymap.set('n', '<down>', vim.diagnostic.goto_next, { silent = true })
                vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { silent = true })
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { silent = true })
            end)
        end
    },
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
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
                "<leader>v",
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
    }
}
