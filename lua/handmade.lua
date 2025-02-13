-- 配置 AHKLS 环境变量以启用 AutoHotkey LSP
-- 格式：$AHKLS = "C:\Portable\vscode-autohotkey2-lsp;C:\Program Files\AutoHotkey;"

-- 伪三元，更好的写法 (a and {b} or {c})[1]
-- 除了 false,Nil 其他都是 true，包括  table，这样就不会在 b 为 false 的情况下返回 c
return {
    -- 配置 nvim-cmp 工厂函数
    -- @param mode 'CR' | 'TAB'
    -- @param shift boolean
    cmp_helper = function(mode, shift)
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
    end,
    override_lsp = function()
        local cfg = require("lspconfig")

        -- :h nvim_open_win
        vim.diagnostic.config({
            float = {
                border = "rounded"
            }
        })

        -- :h lspconfig-global-defaults
        -- 深拷贝是必要的
        cfg.util.default_config = vim.tbl_deep_extend(
            'force',
            cfg.util.default_config, -- builitin 是必要的
            { capabilities = require('cmp_nvim_lsp').default_capabilities() },
            {
                -- :h lsp-handlers
                handlers = {
                    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
                    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
                },
                capabilities = {
                    textdocument = {
                        foldingrange = {
                            dynamicregistration = false,
                            linefoldingonly = true,
                        },
                    }
                }
            }
        )
    end,
    add_lsp = function()
        local configs_all = require('lspconfig.configs')
        if not configs_all.ahkv2 and vim.env.AHKLS then
            local lsp, interpreter = unpack(vim.split(vim.env.AHKLS, ";"))
            -- :h lspconfig-new
            configs_all.ahkv2 = {
                -- https://github.com/thqby/vscode-autohotkey2-lsp?tab=readme-ov-file#use-in-other-editors
                default_config = {
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
                }
            }
            require('lspconfig').ahkv2.setup({})
        end
    end
}
