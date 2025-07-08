return {
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
