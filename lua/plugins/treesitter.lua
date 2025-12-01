local LazyTreesitter = { "VeryLazy", "BufReadPost", "BufNewFile" }

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false, -- 根据文档，不推荐懒加载
        branch = "main",
        config = function(_, opts)
            local ts = require("nvim-treesitter")

            local lang = { "go", "typescript", "tsx", "html", "http", "javascript", "styled", "jsdoc", "json", "vue",
                "yaml", "toml", "markdown", "markdown-inline", "latex" }
            ts.install(lang)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = require("handmade").lang2ft(lang),
                callback = function(e)
                    vim.treesitter.start(e.buf)
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            ts.setup(opts)
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = LazyTreesitter,
        opts = {}
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = LazyTreesitter,
        branch = "main",
        opts = {
            select = {
                enable = true,
                lookahead = true,
                selection_modes = {
                    ['@function.outer'] = 'v',
                    ['@block.outer'] = 'V',
                },
                include_surrounding_whitespace = true,
            },
        },
        config = function(_, opts)
            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")

            local select_keys = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ao"] = "@block.outer",
                ["io"] = "@block.inner",
                ["av"] = "@assignment.outer",
                ["iv"] = "@assignment.inner",
            }

            for k, p in pairs(select_keys) do
                vim.keymap.set({ "x", "o" }, k, function()
                    select.select_textobject(p, "textobjects")
                end)
            end

            vim.keymap.set({ "n", "x", "o" }, "[]", function()
                move.goto_previous_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[[", function()
                move.goto_previous_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "][", function()
                move.goto_next_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]]", function()
                move.goto_next_start("@function.outer", "textobjects")
            end)

            require("nvim-treesitter-textobjects").setup(opts)
        end
    },
    {
        "windwp/nvim-ts-autotag",
        ft = { "vue", "html", "typescriptreact", "javascriptreact", "xml" },
        opts = {},
    },
    {
        "brenoprata10/nvim-highlight-colors",
        ft = { "vue", "css", "less", "html", "typescriptreact", "javascriptreact", "dart" },
        opts = {
            render = "virtual",
            enable_named_colors = false,
            enable_tailwind = false,
            virtual_symbol = "❆ ",
        },
    },
}
