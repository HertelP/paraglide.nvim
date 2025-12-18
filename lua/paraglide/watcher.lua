local M = {}

local config = require("paraglide.config")

local watchers = {}

---@param callback function Callback to execute when files change
function M.setup(callback)
    local project_root = config.get("project_root")
    local messages_dir = project_root .. "/.inlang/messages"

    local stat = vim.loop.fs_stat(messages_dir)
    if not stat or stat.type ~= "directory" then
        return
    end

    local handle = vim.loop.new_fs_event()

    handle:start(messages_dir, { recursive = false }, function(err, filename, events)
        if err then
            vim.notify("Paraglide watcher error: " .. err, vim.log.levels.ERROR)
            return
        end

        if filename and filename:match("%.json$") then
            if not M.debounce_timer then
                M.debounce_timer = vim.defer_fn(function()
                    callback()
                    M.debounce_timer = nil
                end, 500)
            end
        end
    end)

    table.insert(watchers, handle)
end

function M.stop()
    for _, handle in ipairs(watchers) do
        handle:stop()
    end
    watchers = {}
end

return M
