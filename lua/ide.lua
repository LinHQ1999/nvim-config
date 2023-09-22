-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- 先加载着，后面搞不好要用
local lc = require('lspconfig')

-- lsp 包管理，没啥好说的
require("mason").setup({})

-- 本身的 lua 开发环境，注意，很重要
-- 必须先于 lsp.setup
require("neodev").setup()

-- 这个我也不知道有什么用，似乎是处理一些加载路径的问题，因为 mason 动态更新环境变量
require("mason-lspconfig").setup({
    -- vue-language-server 就是 volar lol
    ensure_installed = { "efm", "vtsls", "html", "jsonls", "cssls", "vuels", "yamlls", "vimls", "lua_ls", "powershell_es" }
})

-- 提前声明以避免写在里面多次 require 出故障
local cmpFeatures = require('cmp_nvim_lsp').default_capabilities()
local stylelint = require("efmls-configs.linters.stylelint")
local eslint = require("efmls-configs.linters.eslint_d")
local eslintfmt = require("efmls-configs.formatters.eslint_d")
local prettier = require("efmls-configs.formatters.prettier")
local efmLangs = {
    vue = { eslint, prettier },
    css = { stylelint, prettier },
    html = { stylelint, prettier },
    javascript = { eslint, eslintfmt },
}
require("mason-lspconfig").setup_handlers({
    function(server)
        lc[server].setup({
            -- -- 启用额外的 lsp 功能，比如代码片段，如果是 coq 还得改这里
            capabilities = cmpFeatures
        })
    end,
    -- 这就是 null-ls 替代品，把命令行 lint 工具包装成 language-server，这样就可以把报错集成到自带的 ls 中
    -- 格式化会和原有 lsc 冲突，由于现在我不知道哪个 api 可以探测到 efm 是否可以格式化，所以映射为 cf 和 pf 两种快捷键
    ["efm"] = function()
        lc.efm.setup({
            init_options = {
                codeAction = true,
                documentFormatting = true,
                documentRangeFormatting = true,
            },
            on_attach = function(client, bufnr)
                vim.api.nvim_create_autocmd('BufWritePre', {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ name = "efm" })
                    end
                })
            end,
            filetypes = vim.tbl_keys(efmLangs),
            settings = {
                rootMarkers = { ".git/" },
                languages = efmLangs
            },
        })
    end,
    ["vuels"] = function()
        lc.vuels.setup({
            capabilities = cmpFeatures,
            init_options = {
                config = {
                    vetur = {
                        completion = {
                            autoImport = true,
                            tagCasing = 'initial'
                        },
                        ignoreProjectWarning = true
                    },
                }
            }
        })
    end,
})

-- 这P插件拆得真的细，感觉不如 coq
local cmp = require("cmp")
-- 图标都需要靠别的插件
local lspkind = require("lspkind")
local ls = require('luasnip')
-- 导入 vscode 的 snippet（麻烦）
require("luasnip.loaders.from_vscode").lazy_load()
-- 就是个 lua 版的看是 tab 还是触发补全的函数
-- 写是不可能自己写的，直接抄 wiki 算了
local need_complete = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
    snippet = {
        expand = function(args)
            ls.lsp_expand(args.body)
        end,
    },
    formatting = {
        -- 抄的，主要就是为了显示下补全源
        format = lspkind.cmp_format({
            mode = "symbol_text",
            menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                nvim_lua = "[Lua]",
                path = "[Path]",
            })
        }),
    },
    -- <Tab> 下一个，<S-Tab> 上一个，直接从 wiki 里抄的
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-d>'] = cmp.mapping.abort(),
        -- 还是和 coc 一样，回车就触发代码片段补全
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif ls.expand_or_jumpable() then
                -- elseif ls.expand_or_locally_jumpable() then
                ls.expand_or_jump()
            elseif need_complete() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif ls.jumpable(-1) then
                ls.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'calc' },
        { name = 'buffer' },
    }
})

vim.keymap.set('n', '<up>', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<down>', vim.diagnostic.goto_next)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- 替换原来的 omnifunc
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        -- 设置下 Trouble？
        vim.keymap.set('n', '<leader>cd', function() require("trouble").open() end, opts)

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        -- vim.keymap.set('n', '<space>wl', function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, opts)
        vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>.', vim.lsp.buf.code_action, opts)

        -- 强制不使用 efm 格式化
        vim.keymap.set('n', '<leader>cf',
            function() vim.lsp.buf.format { filter = function(client) return client.name ~= 'efm' end } end,
            opts)
        -- 格式化选中区域
        vim.keymap.set('v', '<leader>cf',
            function() vim.lsp.buf.format { filter = function(client) return client.name ~= 'efm' end } end,
            opts)
        -- 强制使用 efm 格式化
        vim.keymap.set('n', '<leader>pf', function() vim.lsp.buf.format { name = "efm" } end, opts)
        vim.keymap.set('v', '<leader>pf', function() vim.lsp.buf.format { name = "efm" } end, opts)
    end,
})
