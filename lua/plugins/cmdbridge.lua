-- 一些调用外部命令行工具的插件

return {
    {
        "NTBBloodbath/rest.nvim",
        ft = "http",
        opts = {
            highlight = {
                enable = true,
                timeout = 150,
            },
            jump_to_request = true,
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>cf",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "eslint_d", "eslint" },
                typescript = { "eslint_d", "eslint" },
                vue = { "eslint_d", "eslint" },
                html = { "prettierd", "prettier", "eslint" },
            },
            -- Set up format-on-save
            -- format_on_save = { timeout_ms = 2500, lsp_fallback = true },
            format_after_save = { lsp_fallback = true },
        },
        init = function()
            -- 让 = 也可以格式化
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
