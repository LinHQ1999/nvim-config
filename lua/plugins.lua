-- config = true 等于 require('foo').setup({})

-- 如果同时指定了 opts 和 config，则需要在 config 中显式调用 setup
-- 如果显式调用需要指定 option，那最好先在 opts 中定义，因为可以自动和别处的 opts 定义合并

-- 非 lua 插件，除了 basic.vim 之外的配置需要写在 init 中
-- lua 插件如果存在非 opts 的选项，则需要在 config 中初始化，写在 init 中如果存在 require('foo') 会导致 lazy 失效 e.g ufo 的配置

-- dependencies 实际上代表关联启动，具体是 before 还是 after 则智能判断，但只要主插件启动了，它的所有 dependencies 无论是否被主插件 require 到都会启动，
-- 有时可能会出现没有 require 但提前启动的情况。
-- 另一个常见用例是 nvim-treesitter 某个插件非常慢，没必要放在 nvim-treesitter 的 dependencies 里一起启动，而是可以指定别的事件如 'VeryLazy' 单独启动。

-- lazy 文档要求这个得在所有 spec 前面
vim.g.mapleader = " "

return {
    {
        "folke/snacks.nvim", -- 放个链接方便看文档：https://github.com/folke/snacks.nvim#-features
        priority = 1000,
        lazy = false,
        keys = {
            { "<leader>gg", function() Snacks.lazygit() end, desc = "启动 lazygit" },
            { "<leader>ms", function() Snacks.notifier.show_history() end, desc = "消息历史" },
            { "g]", function() Snacks.words.jump(1, true) end, desc = "跳转下一个 Symbol" },
            { "g[", function() Snacks.words.jump(-1, true) end, desc = "跳转上一个 Symbol" },
            -- 下面是 picker 专用快捷键
            { "<leader>lf", function() Snacks.picker.smart() end, desc = "文件（Explorer & 最近）" },
            { "<leader>lr", function() Snacks.picker.recent() end, desc = "文件（最近）" },
            { "<leader>lg", function() Snacks.picker.grep() end, desc = "内容搜索" },
            { "<leader>lb", function() Snacks.picker.buffers() end, desc = "Buffer 搜索" },
            { "<leader>l/", function() Snacks.picker.lines() end, desc = "文件内搜索" },
            { "<F1>", function() Snacks.picker.help() end, desc = "Manual 搜索" },
            { "<leader>l:", function() Snacks.picker.command_history() end, desc = "Ex 命令搜索" },
            { "<leader>lq", function() Snacks.picker.qflist() end, desc = "Quickfix 搜索" },
            { "<leader>ll", function() Snacks.picker.loclist() end, desc = "loclist 搜索" },
            { "<leader>lp", function() Snacks.picker.lazy() end, desc = "查看插件定义" },
            { "<leader>lh", function() Snacks.picker.highlights() end, desc = "Highlights 搜索" },
            { "<leader>lc", function() Snacks.picker.projects() end, desc = "CD 路径搜索" },
            { "<leader>la", function() Snacks.picker.autocmds() end, desc = "Autocmds 搜索" },
            { "<leader>lm", function() Snacks.picker.keymaps() end, desc = "搜索快捷键" },
        },
        opts = {
            bigfile = { enabled = true },
            indent = { enabled = true },
            notifier = {
                timeout = 1500,
                top_down = false
            },
            picker = {
                layout = { preset = function() return vim.o.columns >= 120 and "telescope" or "vertical" end },
                matcher = { frecency = true },
                win = {
                    input = {
                        keys = {
                            ["<Esc>"] = { "close", mode = { "n", "i" } },
                            ["<Up>"] = { "history_back", mode = { "n", "i" } },
                            ["<Down>"] = { "history_forward", mode = { "n", "i" } },
                            ["<C-u>"] = { "<c-s-u>", mode = { "i" }, expr = true, desc = "Delete all" },
                            ["<C-x>"] = { "edit_split", mode = { "i", "n" } },
                        }
                    }
                }
            },
            statuscolumn = {},
            input = {},
            words = { debounce = 1000 }
        },
        config = function(_, opts)
            local hm = require('handmade')
            hm.reg_lsp_progress()
            hm.reg_nvim_tree_rename()
            require('snacks').setup(opts)
        end
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 999,
        lazy = false,
        config = function()
            vim.cmd("colorscheme catppuccin-latte")
        end
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },
    {
        "tpope/vim-fugitive",
        keys = {
            { "<Leader>gs",  "<Cmd>G<cr>" },
            { "<Leader>gps", "<Cmd>Git push<cr>" },
            { "<Leader>gpl", "<Cmd>Git pull<cr>" },
            { "<Leader>gla", "<Cmd>Gclog<cr>" },
        },
        cmd = { "G", "Git", "GcLog", "Gdiffs" }
    },
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            current_line_blame = true,
            signcolumn = true,
            linehl = false,
            current_line_blame_opts = {
                delay = 1000,
            },
        },
    },
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },
    {
        "kyazdani42/nvim-tree.lua",
        keys = {
            { "<leader>pd", "<Cmd>NvimTreeFindFileToggle<cr>", desc = "开关 NvimTree" }
        },
        opts = {
            disable_netrw = true,
            open_on_tab = false,
            -- :cd 时自动切换树
            sync_root_with_cwd = true,
            view = {
                adaptive_size = true,
            },
            update_focused_file = {
                -- 切换到buffer时跟踪显示
                enable = true,
                update_root = false,
                ignore_list = {},
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                theme = "auto",
                section_separators = { left = "", right = "" },
                component_separators = { left = "", right = "" },
                globalstatus = false,
            },
            sections = {
                lualine_b = { "branch", "diff" },
                lualine_c = { { "filename", newfile_status = true, path = 1 } },
                lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
                lualine_y = { "%2p%%❆ %-3L" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_c = { { "filename", path = 1 } },
                lualine_x = {},
                lualine_y = { "%2p%%❆ %-3L", "location" },
            },
            tabline = {
                lualine_a = {
                    {
                        "buffers",
                        mode = 4,
                        use_mode_colors = true,
                        buffers_color = {
                            -- active = 'lualine_a_normal',
                            inactive = "lualine_b_normal",
                        },
                    },
                },
                lualine_z = {
                    {
                        "tabs",
                        mode = 1,
                        tabs_color = {
                            active = "lualine_a_normal",
                            inactive = "lualine_b_normal",
                        },
                    },
                },
            },
            extensions = {
                "fugitive",
                "lazy",
                "mason",
                "nvim-dap-ui",
                "nvim-tree",
                "quickfix",
                "trouble",
            },
        },
        init = function()
            vim.o.showmode = false
            vim.o.laststatus = 2
            vim.o.showtabline = 2
        end
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {}
    },
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        opts = {}
    },
    {
        "justinmk/vim-sneak",
        event = "VeryLazy",
        init = function()
            vim.g["sneak#label"] = 1
        end,
    },
    {
        "folke/todo-comments.nvim",
        keys = {
            { "<leader>xX", "<cmd>Trouble todo<cr>",                      desc = "Show todo in trouble" },
            { "<leader>lt", function() Snacks.picker.todo_comments() end, desc = "Show todo in trouble", }
        },
        opts = {},
    },
    { "nmac427/guess-indent.nvim",    opts = {} },
    { "kyazdani42/nvim-web-devicons", lazy = true },
    { "sainnhe/forest-night",         lazy = true },
    { "folke/tokyonight.nvim",        lazy = true },
    { "olimorris/onedarkpro.nvim",    lazy = true },
}
