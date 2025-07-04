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
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            { "<leader>gg", function() Snacks.lazygit() end, desc = "启动 lazygit" },
            { "<leader>ms", function() Snacks.notifier.show_history() end, desc = "消息历史" }
        },
        opts = {
            bigfile = { enabled = true },
            indent = { enabled = true },
            notifier = {
                timeout = 500,
                top_down = false
            },
        },
        config = function(_, opts)
            require('handmade').reg_lsp_progress()
            require('snacks').setup(opts)
        end
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 999,
        lazy = false,
        config = function()
            vim.cmd([[colorscheme catppuccin-latte]])
        end
    },
    {
        'stevearc/dressing.nvim',
        event = "VeryLazy",
        opts = {},
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
        cmd = { "NvimTreeFindFileToggle" },
        dependencies = {
            {
                "antosha417/nvim-lsp-file-operations",
                main = "lsp-file-operations",
                opts = {}
            }
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
        "nvim-telescope/telescope.nvim",
        version = "~0.1.0",
        cmd = { "Telescope" },
        keys = {
            { "<Leader>lf", "<Cmd>Telescope find_files<CR>" },
            { "<Leader>lg", "<Cmd>Telescope live_grep<CR>" },
            { "<Leader>lb", "<Cmd>Telescope buffers<CR>" },
            { "<Leader>lr", "<Cmd>Telescope oldfiles<CR>" },
            { "<Leader>lv", "<Cmd>Telescope vim_options<CR>" },
            { "<Leader>ll", "<Cmd>Telescope loclist<CR>" },
            { "<Leader>lm", "<Cmd>Telescope marks<CR>" },
            { "<Leader>l/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>" },
            { "<Leader>lq", "<Cmd>Telescope quickfix<CR>" },
            { "<Leader>lh", "<Cmd>Telescope highlights<CR>" },
            { "<Leader>la", "<Cmd>Telescope autocommands<CR>" },
            { "<F1>",       "<Cmd>Telescope help_tags<CR>" },
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<C-u>"] = false,
                    },
                },
                preview = {
                    filesize_limit = 1,
                    treesitter = {
                        disable = { "javascript", "css" },
                    },
                },
            },
            pickers = {
                live_grep = {
                    debounce = 500,
                    glob_pattern = {
                        "!*.{bundle,min}.{js,css}",
                        "!*-lock.*",
                        "!{built,lib,plugin,*vnc,rdp,v,node_modules}/",
                    },
                },
            },
        },
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
        },
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        lazy = true,
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },
    {
        "justinmk/vim-sneak",
        event = "VeryLazy",
        init = function()
            vim.g["sneak#label"] = 1
        end,
    },
    {
        -- 可以被 trouble 和 telescope 依赖
        "folke/todo-comments.nvim",
        cmd = { "TodoLocList", "TodoTelescope" },
        keys = {
            { "<leader>xX", "<cmd>Trouble todo<cr>", desc = "Show todo in trouble", }
        },
        opts = {},
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "folke/trouble.nvim"
        },
    },
    { "nmac427/guess-indent.nvim",    opts = {} },
    { "kyazdani42/nvim-web-devicons", lazy = true },
    { "sainnhe/forest-night",         lazy = true },
    { "folke/tokyonight.nvim",        lazy = true },
    { "olimorris/onedarkpro.nvim",    lazy = true },
}
