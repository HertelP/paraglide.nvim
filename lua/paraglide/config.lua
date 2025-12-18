local M = {}

-- Default configuration
local defaults = {
    project_root = vim.fn.getcwd(),
    default_locale = "en",
    virtual_text = {
        enabled = true,
        prefix = "▸ ",
        highlight_group = "Comment",
    },
    auto_update = true,
    filetypes = {},
    messages_dir = nil,
}

local configuration = {}

---@param user_config table User-provided configuration
function M.setup(user_config)
    configuration = vim.tbl_deep_extend("force", defaults, user_config or {})
end

---@param key string The configuration key (supports nested keys with dots)
---@return any The configuration value
function M.get(key)
    if not next(configuration) then
        configuration = defaults
    end

    local keys = vim.split(key, ".", { plain = true })
    local value = configuration

    for _, k in ipairs(keys) do
        if type(value) == "table" then
            value = value[k]
        else
            return nil
        end
    end

    return value
end

---@param key string The configuration key (supports nested keys with dots)
---@param value any The value to set
function M.set(key, value)
    local keys = vim.split(key, ".", { plain = true })
    local current = configuration

    for i = 1, #keys - 1 do
        local k = keys[i]
        if not current[k] then
            current[k] = {}
        end
        current = current[k]
    end

    current[keys[#keys]] = value
end

---@return table
function M.get_all()
    if not next(configuration) then
        configuration = defaults
    end
    return configuration
end

return M
