-- 配置 AHKLS 环境变量以启用 AutoHotkey LSP
-- 格式：$AHKLS = "C:\Portable\vscode-autohotkey2-lsp;C:\Program Files\AutoHotkey;"

-- 伪三元，更好的写法 (a and {b} or {c})[1]
-- 除了 false,Nil 其他都是 true，包括  table，这样就不会在 b 为 false 的情况下返回 c

local M = {}

M.cmp_helper = function(mode, shift)
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    -- helper 备用
    local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    if mode == 'CR' then
        return cmp.mapping(function(fallback)
            if cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand()
                else
                    cmp.confirm({
                        select = true,
                        -- 如果补全时光标在单词中间，直接替换光标后整个单词而不是追加补全
                        behavior = cmp.ConfirmBehavior.Replace
                    })
                end
            else
                fallback()
            end
        end)
    elseif mode == 'TAB' then
        return cmp.mapping(function(fallback)
            local operator, jumpmode
            if (shift) then
                operator, jumpmode = 'select_prev_item', -1
            else
                operator, jumpmode = 'select_next_item', 1
            end
            -- 让 snip 跳转优先级高于补全，此时仍可用 <C-n> 进行补全选择
            if luasnip.locally_jumpable(jumpmode) then
                vim.print(operator, jumpmode)
                luasnip.jump(jumpmode)
            elseif cmp.visible() then
                cmp[operator]()
            else
                fallback()
            end
        end, { "i", "s" })
    end
end

M.get_mason_path = function(package)
    -- 获取 package 路径
    return vim.fs.joinpath(vim.env.MASON, 'packages', package)
end

M.config_lsp = function(self)
    -- :h nvim_open_win
    vim.diagnostic.config({
        severity_sort = true,
        float = {
            border = 'rounded',
            source = 'if_many'
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '󰅚 ',
                [vim.diagnostic.severity.WARN] = '󰀪 ',
                [vim.diagnostic.severity.INFO] = '󰋽 ',
                [vim.diagnostic.severity.HINT] = '󰌶 ',
            }
        },
        virtual_lines = true
    })

    -- 深拷贝是必要的
    vim.lsp.config('*', vim.tbl_deep_extend(
        'force',
        { capabilities = require('blink.cmp').get_lsp_capabilities() },
        {
            capabilities = {
                textDocument = {
                    semanticTokens = {
                        multilineTokenSupport = true,
                    },
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    },
                }
            }
        }
    ))

    vim.lsp.config('powershell_es', {
        bundle_path = self.get_mason_path("powershell-editor-services"),
    })

    local inlayCfg = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
    }
    vim.lsp.config('vtsls', {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        settings = {
            typescript = { inlayHints = inlayCfg },
            javascript = { inlayHints = inlayCfg },
            vtsls = {
                tsserver = {
                    globalPlugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = vim.fs.joinpath(
                                self.get_mason_path("vue-language-server"),
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

    if vim.env.AHKLS then
        local lsp, interpreter = unpack(vim.split(vim.env.AHKLS, ";"))
        vim.lsp.config('ahkv2', {
            autostart = true,
            cmd = {
                "node",
                vim.fs.joinpath(lsp, 'server', 'dist', 'server.js'),
                "--stdio"
            },
            filetypes = { "ahk", "autohotkey", "ah2" },
            init_options = {
                locale = "zh-cn",
                InterpreterPath = vim.fs.joinpath(interpreter, 'v2', 'AutoHotkey.exe'),
            },
            single_file_support = true,
            flags = { debounce_text_changes = 500 },
        })
        vim.lsp.enable('ahkv2')
    end
end

return M
