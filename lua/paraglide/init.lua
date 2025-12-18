local M = {}

local parser = require("paraglide.parser")
local display = require("paraglide.display")
local config = require("paraglide.config")
local watcher = require("paraglide.watcher")

-- Plugin state
local state = {
  enabled = true,
  locale = "en",
  translations = {},
  namespace = vim.api.nvim_create_namespace("paraglide"),
  watchers = {},
}

---Setup the plugin with user configuration
---@param user_config table|nil User configuration
function M.setup(user_config)
  user_config = user_config or {}
  config.setup(user_config)

  state.locale = config.get("default_locale")

  -- Create user commands
  vim.api.nvim_create_user_command("ParaglideToggle", M.toggle, {})
  vim.api.nvim_create_user_command("ParaglideSetLocale", function(args)
    if args.args ~= "" then
      M.set_locale(args.args)
    end
  end, { nargs = 1 })
  vim.api.nvim_create_user_command("ParaglideRefresh", M.refresh, {})

  -- Initial setup
  M.refresh()

  -- Set up auto-update if enabled
  if config.get("auto_update") then
    watcher.setup(function()
      M.refresh()
    end)
  end
end

---Toggle virtual text display
function M.toggle()
  state.enabled = not state.enabled
  if state.enabled then
    M.refresh()
    vim.notify("Paraglide: enabled", vim.log.levels.INFO)
  else
    M.clear()
    vim.notify("Paraglide: disabled", vim.log.levels.INFO)
  end
end

---Set the current locale
---@param locale string The locale to switch to
function M.set_locale(locale)
  if state.translations[locale] == nil then
    vim.notify("Paraglide: locale '" .. locale .. "' not found", vim.log.levels.WARN)
    return
  end
  state.locale = locale
  M.refresh()
  vim.notify("Paraglide: switched to locale '" .. locale .. "'", vim.log.levels.INFO)
end

---Refresh translations and update display
function M.refresh()
  -- Load translations
  state.translations = parser.load_translations()

  if vim.tbl_isempty(state.translations) then
    vim.notify("Paraglide: no translation files found", vim.log.levels.WARN)
    return
  end

  -- Set default locale if not found
  if state.translations[state.locale] == nil then
    state.locale = next(state.translations)
  end

  -- Update all visible buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.update_buffer(bufnr)
    end
  end
end

---Update virtual text for a specific buffer
---@param bufnr number Buffer number
function M.update_buffer(bufnr)
  if not state.enabled then
    return
  end

  -- Clear existing marks in this buffer
  vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local current_translations = state.translations[state.locale] or {}

  for line_idx, line in ipairs(lines) do
    -- Find all message calls in this line
    local message_calls = parser.find_message_calls(line)

    for _, call in ipairs(message_calls) do
      local message_key = call.key
      local translation = current_translations[message_key]

      if translation then
        -- Create virtual text
        local virt_text = display.format_virtual_text(translation)

        -- Set extmark
        pcall(function()
          vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line_idx - 1, 0, {
            virt_text = virt_text,
            virt_text_pos = "eol",
            hl_group = config.get("virtual_text").highlight_group,
          })
        end)
      end
    end
  end
end

---Clear all virtual text
function M.clear()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)
    end
  end
end

---Get current state (for debugging)
---@return table
function M.get_state()
  return {
    enabled = state.enabled,
    locale = state.locale,
    available_locales = vim.tbl_keys(state.translations),
    translations_count = vim.tbl_count(state.translations[state.locale] or {}),
  }
end

-- Auto-update on buffer enter/write
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("paraglide_buf_enter", { clear = true }),
  callback = function(args)
    if state.enabled then
      M.update_buffer(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("paraglide_buf_write", { clear = true }),
  callback = function(args)
    if state.enabled then
      M.update_buffer(args.buf)
    end
  end,
})

return M
