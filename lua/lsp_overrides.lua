-- NOTE: 之所以要放这里而不是 lsp/，是因为 rtp 中 nvim-lspconfig/lsp 在 .config/lsp 之后加载，会覆盖
-- tbl_deep_extend 行为作为数组用的 table 会被覆盖：E.g. { "a",  "b" } 会被 { "a" } 覆盖为 { "a" }
-- 见 :h lsp-config

local M = {}

M['*'] = {
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

M.gopls = {
    settings = {
        gopls = {
            ["ui.semanticTokens"] = true,
            ["ui.inlayHints.hints"] = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true
            }
        }
    }
}

M.vtsls = {
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    settings = {
        typescript = {
            inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                -- variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            }
        },
        javascript = {
            inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                -- variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            }
        },
        vtsls = {
            tsserver = {
                globalPlugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.fs.joinpath(
                            require('handmade').get_mason_path("vue-language-server"),
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
}

M.bashls = {
    filetypes = { "bash", "sh", "zsh" },
}

M.powershell_es = {
    bundle_path = require('handmade').get_mason_path("powershell-editor-services"),
}

return M
