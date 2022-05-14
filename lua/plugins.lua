-- (treesitter)
require('nvim-treesitter.configs').setup {
    highlight = { enable = true, },
    indent = { enable = { "jsdoc" }}
}

-- (tree)
require('nvim-tree').setup {
  open_on_tab = false,
  -- :cd 时自动切换树
  update_cwd = true,
  update_focused_file = {
    -- 切换到buffer时跟踪显示
    enable = true,
    update_cwd = false,
    ignore_list = {},
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  ignore_ft_on_setup = {}
}

-- (rest)
require('rest-nvim').setup({
    highlight = {
        enable = true,
        timeout = 150,
    },
    jump_to_request = true
})