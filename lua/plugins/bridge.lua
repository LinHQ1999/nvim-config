-- 一些调用外部命令行工具或者 API 的插件
return {
    {
        "stevearc/conform.nvim",
        event = { "VeryLazy" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true })
                end,
                desc = "Conform 格式化",
            },
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
                -- 这两个同时需要 lsp 和 eslint_d
                typescriptreact = { lsp_format = "first", "eslint_d" },
                typescript = { lsp_format = "first", "eslint_d" },
            },
            default_format_opts = {
                timeout_ms = 3500,
                lsp_format = "fallback",
                stop_after_first = false,
            },
            -- 和 conform.format(opts) 一致，会传给它，但现在似乎有 bug 需要手动传
            format_on_save = {
                undojoin = false
            },
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
            { "nvim-neotest/nvim-nio" },
        },
        keys = {
            {
                "<leader>dd",
                function()
                    require("dapui").toggle()
                end,
                desc = "切换 Debug 界面",
            },
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "切换断点",
            },
            {
                "<F5>",
                function()
                    require("dap").continue()
                end,
                desc = "下一断点",
            },
            {
                "<F8>",
                function()
                    require("dap").step_into()
                end,
                desc = "步入",
            },
            {
                "<F10>",
                function()
                    require("dap").step_over()
                end,
                desc = "步过",
            },
        },
        config = function()
            vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "Error", linehl = "Pmenu", numhl = "" })
        end,
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
    { "ravitemer/mcphub.nvim", lazy = true },
    {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanionChat", "CodeCompanionCmd", "CodeCompanionActions", "CodeCompanion" },
        tag = "v17.33.0",
        opts = {
            adapters = {
                acp = {
                    claude_code = function()
                        return require("codecompanion.adapters").extend("claude_code", {
                            env = {
                                ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
                            },
                        })
                    end,
                },
            },
            strategies = {
                chat = {
                    adapter = {
                        name = "deepseek",
                        model = "deepseek-chat",
                    }
                },
                inline = {
                    adapter = {
                        name = "deepseek",
                        model = "deepseek-reasoner"
                    },
                },
                cmd = {
                    adapter = {
                        name = "deepseek",
                        model = "deepseek-chat"
                    },
                }
            },
            extensions = {
                mcphub = {
                    callback = "mcphub.extensions.codecompanion",
                    opts = {
                        make_vars = true,
                        make_slash_commands = true,
                        show_result_in_chat = true
                    }
                }
            },
            language = "Chinese",
        }
    }
}
