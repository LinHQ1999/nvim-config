-- 配置 AHKLS 环境变量以启用 AutoHotkey LSP
-- 格式：$AHKLS = "C:\Portable\vscode-autohotkey2-lsp;C:\Program Files\AutoHotkey;"

-- 伪三元，更好的写法 (a and {b} or {c})[1]
-- 除了 false,Nil 其他都是 true，包括  table，这样就不会在 b 为 false 的情况下返回 c

local M = {}

---获取 package 路径
M.get_mason_path = function(package)
    return vim.fs.joinpath(vim.env.MASON, 'packages', package)
end

---配置额外的 LS 功能
M.config_lsp = function()
    -- :h nvim_open_win
    vim.diagnostic.config({
        severity_sort = true,
        float = {
            border = 'rounded',
            source = 'if_many'
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '󰅚 ',
                [vim.diagnostic.severity.WARN] = '󰀪 ',
                [vim.diagnostic.severity.INFO] = '󰋽 ',
                [vim.diagnostic.severity.HINT] = '󰌶 ',
            }
        },
        virtual_lines = true
    })

    -- :h lsp-config
    vim.lsp.config('*', {
        capabilities = {
            textDocument = {
                semanticTokens = {
                    multilineTokenSupport = true,
                },
                foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                },
            }
        }
    })

    if vim.env.AHKLS then
        local lsp, interpreter = unpack(vim.split(vim.env.AHKLS, ";"))
        vim.lsp.config('ahkv2', {
            autostart = true,
            cmd = {
                "node",
                vim.fs.joinpath(lsp, 'server', 'dist', 'server.js'),
                "--stdio"
            },
            filetypes = { "ahk", "autohotkey", "ah2" },
            init_options = {
                locale = "zh-cn",
                InterpreterPath = vim.fs.joinpath(interpreter, 'v2', 'AutoHotkey.exe'),
            },
            single_file_support = true,
            flags = { debounce_text_changes = 500 },
        })
        vim.lsp.enable('ahkv2')
    end
end

---平替 fidget.nvim 显示 lsp 进度信息
M.reg_lsp_progress = function()
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
                    notif.icon = #progress[client.id] == 0
                        and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1] -- WARN: LSP 问题，有头绪了修
                end,
            })
        end,
    })
end

---处理文件重命名通知 LS 重构
M.reg_nvim_tree_rename = function()
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

return M
