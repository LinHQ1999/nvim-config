-- 一些调用外部命令行工具的插件
return {
    {
        "stevearc/conform.nvim",
        cond = false,
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
                typescript = { "prettierd", "eslint" },
                vue = { "eslint_d", "eslint" },
                html = { "prettierd", "prettier", "eslint" },
            },
            -- Set up format-on-save
            format_on_save = { timeout_ms = 2500, lsp_fallback = true },
            -- format_after_save = { lsp_fallback = true },
        },
        init = function()
            -- 让 = 也可以格式化
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            { "mfussenegger/nvim-dap" },
            { "nvim-neotest/nvim-nio" }
        },
        keys = {
            { "<leader>dt", function() require("dapui").toggle() end, desc = "切换 Debug 界面" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "切换断点" },
            { "<F5>", function() require("dap").continue() end, desc = "下一断点" },
            { "<F8>", function() require("dap").step_into() end, desc = "步入" },
            { "<F10>", function() require("dap").step_over() end, desc = "步过" },
        },
        config = function()
            vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'Error', linehl = 'Pmenu', numhl = '' })
        end
    }
}
