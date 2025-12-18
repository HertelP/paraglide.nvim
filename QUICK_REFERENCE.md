# paraglide.nvim - Quick Reference Card

## Installation (Choose one)

### lazy.nvim
```lua
{
  dir = "/home/hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup()
  end,
}
```

### packer.nvim
```lua
use {
  "/home/hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup()
  end,
}
```

### vim-plug
```vim
Plug "/home/hertelp/paraglide.nvim"
lua require("paraglide").setup()
```

## Configuration

### Basic (Copy-paste ready)
```lua
require("paraglide").setup({
  project_root = vim.fn.getcwd(),
  default_locale = "en",
})
```

### Full (All options)
```lua
require("paraglide").setup({
  -- Where .inlang folder is located
  project_root = vim.fn.getcwd(),
  
  -- Initial language
  default_locale = "en",
  
  -- Virtual text appearance
  virtual_text = {
    enabled = true,
    prefix = "▸ ",              -- Change this to customize
    highlight_group = "Comment", -- Change color scheme
  },
  
  -- Watch files for changes
  auto_update = true,
  
  -- Only enable for these file types (empty = all)
  filetypes = {},
})
```

## Commands

```
:ParaglideToggle              " Toggle on/off
:ParaglideSetLocale de        " Switch to German
:ParaglideSetLocale es        " Switch to Spanish
:ParaglideRefresh             " Manual refresh
```

## Key Bindings (Optional)

Add to your config:

```lua
local paraglide = require("paraglide")

-- Toggle translations
vim.keymap.set("n", "<leader>pt", paraglide.toggle, {
  noremap = true,
  silent = true,
})

-- Switch locale
vim.keymap.set("n", "<leader>pl", function()
  vim.ui.input({ prompt = "Locale: " }, function(input)
    if input then paraglide.set_locale(input) end
  end)
end, { noremap = true, silent = true })
```

## Lua API

```lua
local paraglide = require("paraglide")

-- Initialize
paraglide.setup(config)

-- Toggle display
paraglide.toggle()

-- Change language
paraglide.set_locale("de")

-- Reload translations
paraglide.refresh()

-- Check state (debugging)
paraglide.get_state()
-- Returns:
-- {
--   enabled = true,
--   locale = "en",
--   available_locales = {"en", "de", "es"},
--   translations_count = 10,
-- }
```

## Common Configurations

### Dark theme with custom color
```lua
-- First create the highlight
vim.api.nvim_set_hl(0, "ParaglideText", {
  fg = "#88BBFF",
  italic = true,
})

require("paraglide").setup({
  virtual_text = {
    prefix = "→ ",
    highlight_group = "ParaglideText",
  },
})
```

### Specific file types only
```lua
require("paraglide").setup({
  filetypes = {
    "javascript",
    "typescript",
    "svelte",
    "vue",
    "jsx",
    "tsx",
  },
})
```

### Disable auto-update (for performance)
```lua
require("paraglide").setup({
  auto_update = false,
})
-- Then use :ParaglideRefresh when needed
```

## Message Patterns

The plugin finds these:

```javascript
m.key()                     ✓ Simple key
m.nested.key()             ✓ Nested keys
m["key"]()                 ✓ Bracket notation
m['key']()                 ✓ Single quotes
m.greeting({...})          ✓ With parameters
{{ m.key() }}              ✓ Svelte templates
{m.key()}                  ✓ JSX/TSX
```

## File Structure Required

```
your-project/
├── .inlang/
│   └── messages/
│       ├── en.json    ← English translations
│       ├── de.json    ← German translations
│       └── es.json    ← Spanish translations
├── src/
│   ├── app.js
│   ├── components.svelte
│   └── ...
└── ...
```

## Translation File Format

```json
{
  "hello": "Hello",
  "greeting": "Hello {name}!",
  "user.profile.title": "User Profile",
  "common.save": "Save",
  "common.cancel": "Cancel"
}
```

## Highlighting Options

Use any of these with `highlight_group`:

```
Comment          Dimmed gray (default)
String           Green
Keyword          Blue
Type             Purple
Constant         Orange
Function         Yellow
LineNr           Gray
NonText          Light gray
DiagnosticHint   Blue hint color
DiagnosticInfo   Green info color
```

Or create custom:

```lua
vim.api.nvim_set_hl(0, "MyColor", { fg = "#FF0000", italic = true })

require("paraglide").setup({
  virtual_text = {
    highlight_group = "MyColor",
  },
})
```

## Troubleshooting

### "no translation files found"
→ Check `.inlang/messages/` directory exists  
→ Verify `project_root` is set correctly  
→ Ensure at least one `.json` file present

### Virtual text not showing
→ `:ParaglideToggle` to enable  
→ Verify file has message calls  
→ `:ParaglideRefresh` to update

### Locale not found
→ Use `:ParaglideSetLocale en` with available locale  
→ Check available: `:lua print(require("paraglide").get_state().available_locales)`

### Performance issues
→ Disable auto-update: `auto_update = false`  
→ Use `:ParaglideToggle` to disable when not needed  
→ Limit to specific filetypes

## Highlight Groups Custom Example

```lua
-- Create custom highlight for translations
vim.api.nvim_set_hl(0, "ParaglideTranslation", {
  fg = "#61AFEF",        -- Blue
  bg = "#282C34",        -- Dark background (optional)
  italic = true,
  bold = false,
})

require("paraglide").setup({
  virtual_text = {
    prefix = "► ",
    highlight_group = "ParaglideTranslation",
  },
})
```

## Performance Tips

1. **Disable on large files**: Use `:ParaglideToggle`
2. **Limit filetypes**: Only enable for relevant files
3. **Disable auto-update**: Set `auto_update = false` for big projects
4. **Manual refresh**: Use `:ParaglideRefresh` when needed

## Tips & Tricks

### Quick locale cycle
```lua
local paraglide = require("paraglide")
local locales = {}
local idx = 0

vim.keymap.set("n", "<leader>pn", function()
  if vim.tbl_isempty(locales) then
    locales = paraglide.get_state().available_locales
  end
  idx = (idx % #locales) + 1
  paraglide.set_locale(locales[idx])
end)
```

### Per-filetype configuration
```lua
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",
  callback = function()
    require("paraglide").toggle()  -- Disable for markdown
  end,
})
```

### Show in statusline
```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      function()
        return "▸ " .. require("paraglide").get_state().locale
      end,
    },
  },
})
```

## File Locations

```
Project root:    /home/hertelp/paraglide.nvim/
Main plugin:     lua/paraglide/init.lua
Docs start:      README.md
Quick help:      QUICKSTART.md
Architecture:    ARCHITECTURE.md
```

## Getting Help

1. **Read docs**: `QUICKSTART.md`, `README.md`
2. **Check config**: See `example-config.lua`
3. **Debug state**: `:lua print(require("paraglide").get_state())`
4. **Test setup**: Go to test-fixture and try examples

---

**Version**: 0.1.0  
**Requires**: Neovim 0.7.0+  
**Dependencies**: None (Pure Lua)
