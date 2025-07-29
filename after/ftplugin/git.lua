vim.wo.foldmethod = "syntax"
vim.wo.foldlevel = 0

local opt = { buffer = true, remap = true }
vim.keymap.set("n", "<Down>", "]/", opt)
vim.keymap.set("n", "<Up>", "[/", opt)
