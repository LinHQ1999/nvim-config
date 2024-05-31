-- config = true 等于 require('foo').setup({})
-- 如果同时指定了 opts 和 config，则需要在 config 中显式调用 setup
-- 非 lua 插件，除了 basic.vim 之外的配置需要写在 init 中
-- lua 插件如果存在非 opts 的选项，则需要在 config 中初始化，写在 init 中如果存在 require() 会导致 lazy 失效 e.g ufo 的配置

vim.g.mapleader = ' '
require('lazy').setup({
    { 'tpope/vim-fugitive', event = 'VeryLazy' },
    {
        'lewis6991/gitsigns.nvim',
        event = 'VeryLazy',
        opts = {
            current_line_blame = true,
            signcolumn = true,
            linehl = false,
            current_line_blame_opts = {
                delay = 1000
            }
        }
    },
    {
        'kevinhwang91/nvim-ufo',
        event = 'VeryLazy',
        opts = {},
        config = function(_, opts)
            local ufo = require('ufo')

            ufo.setup(opts)

            vim.o.foldcolumn = '0'
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            vim.keymap.set('n', 'zR', ufo.openAllFolds)
            vim.keymap.set('n', 'zM', ufo.closeAllFolds)
        end,
        dependencies = {
            { 'kevinhwang91/promise-async' }
        }
    },
    {
        'nvim-lua/plenary.nvim',
        lazy = true
    },
    {
        'NTBBloodbath/rest.nvim',
        ft = 'http',
        opts = {
            highlight = {
                enable = true,
                timeout = 150,
            },
            jump_to_request = true
        }
    },
    {
        'neoclide/coc.nvim',
        branch = 'release',
        build = ':CocUpdate',
        event = 'VeryLazy',
        init = function()
            -- vim.o 则是字符串
            vim.opt.shortmess:append('c')
            vim.o.signcolumn = 'number'
            vim.g.coc_global_extensions = { "coc-clangd", "coc-css", "coc-cssmodules", "coc-dictionary", "coc-docker", "coc-emmet", "coc-eslint", "coc-go", "coc-html", "coc-java", "coc-json", "coc-lists", "coc-marketplace", "coc-omni", "coc-pairs", "coc-powershell", "coc-prisma", "coc-pyright", "coc-rust-analyzer", "coc-sh", "coc-snippets", "coc-stylelintplus", "coc-sumneko-lua", "coc-svelte", "coc-svg", "coc-toml", "coc-tsserver", "coc-unocss", "coc-vetur", "coc-vimlsp", "coc-xml", "coc-yaml", "@yaegassy/coc-tailwindcss3" }
        end,
        dependencies = {
            {
                'liuchengxu/vista.vim',
                init = function()
                    vim.g.vista_cursor_delay = 60
                    vim.g.vista_sidebar_position = "vertical botright"
                    vim.g.vista_default_executive = "coc"
                end
            }
        }
    },
    { 'fatih/vim-go',       ft = 'go' },
    --[[ {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers",
        cmd = "Neorg",
        ft = "norg",
        opts = {
            load = {
                ["core.defaults"] = {},      -- Loads default behaviour
                ["core.concealer"] = {},     -- Adds pretty icons to your documents
                ["core.ui.calendar"] = {},     -- Adds pretty icons to your documents
                ["core.dirman"] = {          -- Manages Neorg workspaces
                    config = {
                        workspaces = {
                            notes = "~/Desktop/备忘录",
                        },
                    },
                },
            },
        },
    } ,]]
    {
        'kyazdani42/nvim-tree.lua',
        cmd = "NvimTreeFindFileToggle",
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
            }
        }
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                theme = 'auto',
                section_separators = { left = '', right = '' },
                component_separators = { left = '', right = '' },
                globalstatus = false
            },
            sections = {
                lualine_b = { 'branch', 'diff' },
                lualine_c = { { 'filename', newfile_status = true, path = 1 } },
                lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
                lualine_y = { '%2p%%❆ %-3L' },
                lualine_z = { '%3l:%-2c' }
            },
            inactive_sections = {
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = {},
                lualine_y = { '%2p%%❆ %-3L', '%3l:%-2c' }
            },
            tabline = {
                lualine_a = { {
                    'buffers',
                    mode = 4,
                    use_mode_colors = true,
                    buffers_color = {
                        -- active = 'lualine_a_normal',
                        inactive = 'lualine_b_normal',
                    }
                } },
                lualine_z = { {
                    'tabs',
                    mode = 1,
                    tabs_color = {
                        active = 'lualine_a_normal',
                        inactive = 'lualine_b_normal',
                    }
                } }
            },
            extensions = {
                'fugitive',
                'nvim-tree',
                'quickfix',
                'lazy'
            }
        },
        config = function(_, opts)
            require('lualine').setup(opts)
            vim.opt.showmode = false
            vim.opt.laststatus = 2
            vim.opt.showtabline = 2
        end,
    },
    {
        'kylechui/nvim-surround',
        event = 'VeryLazy',
        config = true
    },
    {
        'numToStr/Comment.nvim',
        event = 'VeryLazy',
        config = true
    },
    {
        'nvim-telescope/telescope.nvim',
        version = "~0.1.0",
        event = "VeryLazy",
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<C-u>"] = false
                    }
                },
                preview = {
                    filesize_limit = 1,
                    treesitter = {
                        disable = { "javascript", "css" }
                    }
                }
            },
            pickers = {
                live_grep = {
                    debounce = 500,
                    glob_pattern = { '!*.{bundle,min}.{js,css}', '!*-lock.*', '!{built,lib,plugin,*vnc,rdp,v,node_modules}/' }
                }
            },
        },
        dependencies = {
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                config = function()
                    require('telescope').load_extension('fzf')
                end
            }
        }
    },
    {
        'justinmk/vim-sneak',
        event = 'VeryLazy',
        init = function()
            vim.g['sneak#label'] = 1
        end
    },
    { 'kyazdani42/nvim-web-devicons', lazy = true },
    { 'sainnhe/forest-night',         lazy = true },
    { 'folke/tokyonight.nvim',        lazy = true },
    { 'olimorris/onedarkpro.nvim',    lazy = true },
    { 'catppuccin/nvim',              name = 'catppuccin', lazy = true },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'VeryLazy',
        config = function (_, opts)
            -- 高级选项，巨幅提升 parser 下载速度
            -- 要求 curl, tar, 且可以在非 admin 下创建 SymbolicLink
            -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#how-will-the-parser-be-downloaded
            require("nvim-treesitter.install").prefer_git = false

            require("nvim-treesitter.configs").setup(opts)
        end,
        opts = {
            ensurse_installed = {
                "c", "lua", "go",
                "typescript", "tsx",
                "html", "http", "javascript", "jsdoc", "json", "vue"
            },
            highlight = {
                enable = true
            },
            indent = {
                enable = true,
                disable = {
                    "javascript"
                }
            }
        },
        dependencies = {
            {
                'lukas-reineke/indent-blankline.nvim',
                main = 'ibl',
                config = true
            },
            {
                'nvim-treesitter/nvim-treesitter-context',
                config = true
            },
            {
                'windwp/nvim-ts-autotag',
                config = true
            }
        }
    },
    {
        'brenoprata10/nvim-highlight-colors',
        opts = {
            render = 'virtual',
            enable_named_colors = false,
            enable_tailwind = false,
            virtual_symbol = '❆ ',
        }
    }
})
