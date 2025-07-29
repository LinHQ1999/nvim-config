-- 一些调用外部命令行工具或者 API 的插件
return {
    {
        "stevearc/conform.nvim",
        event = { "VeryLazy" },
        cmd = { "ConformInfo" },
        keys = {
            { "<leader>cf", function() require("conform").format() end, desc = "Conform 格式化", },
        },
        opts = {
            formatters_by_ft = {
                -- NOTE: 这里实际上可以用 conform.format 中的 { id, name, filter, formatting_options } 参数
                -- 见 https://github.com/stevearc/conform.nvim/issues/565#issuecomment-2453052532
                -- 这里没定义的那就是用 lsp 了
                python = { "black" },
                yaml = { "yamlfmt" },
                go = { "goimports" },
                bash = { "shfmt" },
                sh = { "shfmt" },
            },
            default_format_opts = {
                timeout_ms = 3500,
                lsp_format = "first",    -- 最先用 lsp 格式化一次
                stop_after_first = false -- lsp 激活的有 vtsls + eslint，则两个都用
            },
            -- 和 conform.format(opts) 一致
            format_on_save = {},
        },
        init = function()
            -- 让 =、gq 也可以格式化
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
            { "<leader>dd", function() require("dapui").toggle() end, desc = "切换 Debug 界面" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "切换断点" },
            { "<F5>", function() require("dap").continue() end, desc = "下一断点" },
            { "<F8>", function() require("dap").step_into() end, desc = "步入" },
            { "<F10>", function() require("dap").step_over() end, desc = "步过" },
        },
        config = function()
            vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'Error', linehl = 'Pmenu', numhl = '' })
        end
    },
    {
        "olimorris/codecompanion.nvim",
        enable = false,
        opts = {
            adapters = {
                deepseek = function()
                    return require("codecompanion.adapters").extend("deepseek", {
                        env = {
                            api_key = ""
                        }
                    })
                end
            },
        },
        event = "InsertEnter"
    },
    {
        "mistweaverco/kulala.nvim",
        keys = {
            { "<leader>rs", desc = "发送请求" },
            { "<leader>ra", desc = "发送所有请求" },
            { "<leader>rb", desc = "Open scratchpad" },
        },
        ft = { "http", "rest" },
        opts = {
            global_keymaps = true,
            global_keymaps_prefix = "<leader>r",
            kulala_keymaps_prefix = "",
        },
    },
}
