-- NOTE: 如果想放 lsp/ 下，需要放到 after/lsp/ 中，否则 rtp 在前会被 nvim-lspconfig/lsp 覆盖掉
-- https://www.reddit.com/r/neovim/comments/1jxv6c0/comment/mmuxvfn/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
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
                -- parameterTypes = { enabled = true },
                -- variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                -- functionLikeReturnTypes = { enabled = true },
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
