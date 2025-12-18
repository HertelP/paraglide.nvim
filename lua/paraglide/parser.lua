local M = {}

local config = require("paraglide.config")

---Load all translation files from .inlang/messages directory
---@return table Table of {locale = {key = translation, ...}, ...}
function M.load_translations()
  local project_root = config.get("project_root")
  local messages_dir = project_root .. "/.inlang/messages"

  -- Check if .inlang/messages directory exists
  local handle = vim.loop.fs_scandir(messages_dir)
  if not handle then
    return {}
  end

  local translations = {}

  while true do
    local name, file_type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    -- Only process .json files
    if file_type == "file" and name:match("%.json$") then
      local locale = name:gsub("%.json$", "")
      local file_path = messages_dir .. "/" .. name

      -- Read and parse JSON file
      local file = io.open(file_path, "r")
      if file then
        local content = file:read("*a")
        file:close()

        local ok, parsed = pcall(vim.json.decode, content)
        if ok then
          translations[locale] = parsed
        else
          vim.notify("Paraglide: failed to parse " .. file_path, vim.log.levels.WARN)
        end
      end
    end
  end

  return translations
end

---Find all Paraglide message calls in a line
---@param line string The line to search
---@return table Array of {key = string, col = number}
function M.find_message_calls(line)
  local calls = {}

  -- Pattern 1: m.messageKey(...) or m["message.key"](...)
  -- Matches: m.key( or m["key"](
  local patterns = {
    -- m.key(...) - simple identifier
    'b[m]%.([%w_]+)%s*%(',
    -- m["key"](...) or m['key'](...)
    'b[m]%[%"([^%"]+)%"%]%s*%(',
    "b[m]%[%'([^%']+)%'%]%s*%(",
  }

  for _, pattern in ipairs(patterns) do
    local pos = 1
    while true do
      local start, finish, key = line:find(pattern, pos)
      if not start then
        break
      end

      table.insert(calls, {
        key = key,
        col = start,
      })

      pos = finish + 1
    end
  end

  return calls
end

---Format a translation for display
---Handles parameters by showing them as placeholders
---@param translation string The translation string
---@return string Formatted translation
function M.format_translation(translation)
  -- Replace parameter placeholders with a simplified format
  -- e.g., "Hello {name}!" becomes "Hello {name}!"
  return translation
end

return M
