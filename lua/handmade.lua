-- 配置 AHKLS 环境变量以启用 AutoHotkey LSP
-- 格式：$AHKLS = "C:\Portable\vscode-autohotkey2-lsp;C:\Program Files\AutoHotkey;"

-- 伪三元，更好的写法 (a and {b} or {c})[1]
-- 除了 false,Nil 其他都是 true，包括  table，这样就不会在 b 为 false 的情况下返回 c

local M = {}

-- 获取 package 路径
function M.get_mason_path(package)
    return vim.fs.joinpath(vim.env.MASON, "packages", package)
end

-- 配置 lsp 相关的快捷键
function M.config_lsp_mapping()
    local lsp_group = vim.api.nvim_create_augroup("LSP", {})
    vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_group,
        callback = function(e)
            -- :h lsp-config
            local client, opts = vim.lsp.get_client_by_id(e.data.client_id), { silent = true, buffer = e.buf }

            if not client then
                return
            end
            -- :h lsp-inlay_hint
            -- :h lsp-method
            -- :h lsp-client
            if client:supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint.enable(true)
            end

            local map = vim.keymap.set
            -- :h grr
            map("n", "gd", function() Snacks.picker.lsp_definitions() end, opts)
            map("n", "gD", function() Snacks.picker.lsp_declarations() end, opts)
            map("n", "grr", function() Snacks.picker.lsp_references() end, opts)
            map("n", "gri", function() Snacks.picker.lsp_implementations() end, opts)
            map("n", "grt", function() Snacks.picker.lsp_type_definition() end, opts)

            -- 调用 vtsls 专用方法
            if client.name == "vtsls" then
                map("n", "<leader>ci", [[<Cmd>VtsExec remove_unused<cr>]], opts)
                map("n", "<leader>cm", [[<Cmd>VtsExec add_missing_imports<cr>]], opts)
            elseif client.name == "gopls" then
                map("n", "<leader>gta", [[<Cmd>GoTagAdd json<cr>]], opts)
                map("n", "<leader>gtr", [[<Cmd>GoTagRm json<cr>]], opts)
                map("n", "<leader>gtc", [[<Cmd>GoTagClear<cr>]], opts)
            end
        end,
    })
end

-- 配置额外的 LS 功能
function M:config_lsp(with_mapping)
    -- :h nvim_open_win
    vim.diagnostic.config({
        severity_sort = true,
        jump = {
            float = true
        },
        float = {
            border = "rounded",
            source = "if_many",
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "󰅚 ",
                [vim.diagnostic.severity.WARN] = "󰀪 ",
                [vim.diagnostic.severity.INFO] = "󰋽 ",
                [vim.diagnostic.severity.HINT] = "󰌶 ",
            },
        },
        virtual_lines = true,
    })

    local cfgs = require("lsp_overrides")
    for k, v in pairs(cfgs) do
        vim.lsp.config(k, v)
    end

    if vim.env.AHKLS then
        local lsp, interpreter = unpack(vim.split(vim.env.AHKLS, ";"))
        vim.lsp.config("ahkv2", {
            autostart = true,
            cmd = {
                "node",
                vim.fs.joinpath(lsp, "server", "dist", "server.js"),
                "--stdio",
            },
            filetypes = { "ahk", "autohotkey", "ah2" },
            init_options = {
                locale = "zh-cn",
                InterpreterPath = vim.fs.joinpath(interpreter, "v2", "AutoHotkey.exe"),
            },
            single_file_support = true,
            flags = { debounce_text_changes = 500 },
        })
        vim.lsp.enable("ahkv2")
    end

    if with_mapping then
        self.config_lsp_mapping()
    end
end

-- 平替 fidget.nvim 显示 lsp 进度信息
function M.reg_lsp_progress()
    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value = ev.data.params
                .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            if not client or type(value) ~= "table" then
                return
            end
            local p = progress[client.id]

            for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == ev.data.params.token then
                    p[i] = {
                        token = ev.data.params.token,
                        msg = ("[%3d%%] %s%s"):format(
                            value.kind == "end" and 100 or value.percentage or 100,
                            value.title or "",
                            value.message and (" **%s**"):format(value.message) or ""
                        ),
                        done = value.kind == "end",
                    }
                    break
                end
            end
            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v)
                return table.insert(msg, v.msg) or not v.done
            end, p)

            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

            vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, {
                id = "lsp_progress",
                title = client.name,
                opts = function(notif)
                    -- WARN: luv 定义 -> 未来需要手动在 .luarc.json 中指定 workspace.userThirdParty
                    notif.icon = #progress[client.id] == 0 and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end,
    })
end

-- 处理文件重命名通知 LS 重构
function M.reg_nvim_tree_rename()
    local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
    vim.api.nvim_create_autocmd("User", {
        pattern = "NvimTreeSetup",
        callback = function()
            local events = require("nvim-tree.api").events
            events.subscribe(events.Event.NodeRenamed, function(data)
                if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
                    data = data
                    Snacks.rename.on_rename_file(data.old_name, data.new_name)
                end
            end)
        end,
    })
end

-- parser table 转换 filetype
function M.lang2ft(lang)
    return vim.iter(lang)
        :map(function(grammer)
            return vim.treesitter.language.get_filetypes(grammer)
        end)
        :flatten()
        :totable()
end

function M.codecompanion_progress()
    local lua_line_comp = require("lualine.component"):extend()

    lua_line_comp.processing = false
    lua_line_comp.spinner_index = 1

    local spinner_symbols = {
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
    }
    local spinner_symbols_len = 10

    -- Initializer
    function lua_line_comp:init(options)
        lua_line_comp.super.init(self, options)

        local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

        vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "CodeCompanionRequest*",
            group = group,
            callback = function(request)
                if request.match == "CodeCompanionRequestStarted" then
                    self.processing = true
                elseif request.match == "CodeCompanionRequestFinished" then
                    self.processing = false
                end
            end,
        })
    end

    -- Function that runs every time statusline is updated
    function lua_line_comp:update_status()
        if self.processing then
            self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
            return spinner_symbols[self.spinner_index]
        else
            return nil
        end
    end

    return lua_line_comp
end

return M
