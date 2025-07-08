local inlayCfg = {
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    variableTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    enumMemberValues = { enabled = true },
}

return {
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
