local M = {}

local config = require("paraglide.config")

---@param translation string The translation text
---@return table Formatted virtual text for extmark
function M.format_virtual_text(translation)
    local prefix = config.get("virtual_text").prefix
    local text = prefix .. translation

    local max_length = 120
    if #text > max_length then
        text = text:sub(1, max_length - 3) .. "..."
    end

    return { { text, config.get("virtual_text").highlight_group } }
end

---@param bufnr number Buffer number
---@param namespace number Namespace ID
---@param line number Line number (0-indexed)
---@param col_start number Start column
---@param col_end number End column
function M.highlight_message_key(bufnr, namespace, line, col_start, col_end)
    pcall(function()
        vim.api.nvim_buf_set_extmark(bufnr, namespace, line, col_start, {
            end_row = line,
            end_col = col_end,
            hl_group = "Search",
        })
    end)
end

return M
