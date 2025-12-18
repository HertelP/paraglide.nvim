# Quick Start Guide

## Installation

### Using lazy.nvim

Add this to your `init.lua`:

```lua
{
  "hertelp/paraglide.nvim",
  lazy = false,
  config = function()
    require("paraglide").setup({
      project_root = vim.fn.getcwd(),
      default_locale = "en",
    })
  end,
}
```

### Using packer.nvim

```lua
use {
  "hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup()
  end,
}
```

### Using vim-plug

```vim
Plug "hertelp/paraglide.nvim"

" In your init.vim or after/plugin file
lua require("paraglide").setup()
```

## Basic Usage

Once installed and configured, the plugin will:

1. **Automatically detect** Paraglide translation files in `.inlang/messages/`
2. **Display translations** as virtual text at the end of lines with message calls
3. **Support multiple locales** - switch between them with commands

### Commands

```
:ParaglideToggle              " Enable/disable virtual text display
:ParaglideSetLocale de        " Switch to German (or any available locale)
:ParaglideRefresh             " Manually refresh translations
```

### Recommended Key Bindings

Add to your Neovim config:

```lua
local paraglide = require("paraglide")

-- Toggle virtual text
vim.keymap.set("n", "<leader>pt", paraglide.toggle, {
  noremap = true,
  silent = true,
  desc = "Toggle Paraglide translations"
})

-- Quick locale switcher
vim.keymap.set("n", "<leader>pl", function()
  vim.ui.input({ prompt = "Locale (en/de/es/...): " }, function(locale)
    if locale and locale ~= "" then
      paraglide.set_locale(locale)
    end
  end)
end, {
  noremap = true,
  silent = true,
  desc = "Switch Paraglide locale"
})
```

## Configuration

### Default Configuration

```lua
require("paraglide").setup({
  -- Directory containing .inlang folder (defaults to current working directory)
  project_root = vim.fn.getcwd(),

  -- Default locale to display when plugin starts
  default_locale = "en",

  -- Virtual text styling
  virtual_text = {
    enabled = true,
    prefix = "▸ ",           -- Text prefix before translation
    highlight_group = "Comment",  -- Neovim highlight group
  },

  -- Auto-update translations when files change on disk
  auto_update = true,

  -- File types to enable for (empty = all file types)
  filetypes = {},  -- e.g., { "javascript", "svelte", "typescript" }
})
```

### Customization Examples

**Change virtual text appearance:**

```lua
require("paraglide").setup({
  virtual_text = {
    prefix = "→ ",
    highlight_group = "Keyword",  -- Use a different highlight group
  },
})
```

**Use a different highlight group:**

Available highlight groups:
- `Comment` - Dimmed gray (default)
- `Keyword` - Colored keywords
- `String` - String color
- `Type` - Type color
- `LineNr` - Line number color
- `NonText` - Non-text gray

Or define your own:

```lua
vim.api.nvim_set_hl(0, "ParaglideText", { fg = "#88BBFF", italic = true })

require("paraglide").setup({
  virtual_text = {
    highlight_group = "ParaglideText",
  },
})
```

**Limit to specific file types:**

```lua
require("paraglide").setup({
  filetypes = { "javascript", "typescript", "svelte", "vue", "jsx", "tsx" },
})
```

**Disable auto-update for performance:**

```lua
require("paraglide").setup({
  auto_update = false,
})
-- Then use :ParaglideRefresh when needed
```

## How It Works

### Message Detection

The plugin finds Paraglide message calls using these patterns:

```javascript
m.hello_world()                    // Simple key
m.greeting({ name: "John" })      // With parameters
m["nested.key"]()                 // Bracket notation
m['nested.key']()                 // Single quotes
{{ m.key() }}                      // In Svelte templates
{m.key()}                          // In JSX/TSX
```

### Translation Display

For each detected message call, the plugin:

1. Extracts the message key (e.g., `"greeting"`)
2. Looks up the translation in the current locale's JSON file
3. Displays it as virtual text at the end of the line

Example:

```javascript
// In code:
console.log(m.greeting({ name: "Alice" }))
// Displays as: ▸ Hello {name}!
```

### Supported File Types

The plugin works with any file type, but is most useful in:

- JavaScript/TypeScript (`.js`, `.ts`)
- JSX/TSX (`.jsx`, `.tsx`)
- Svelte (`.svelte`)
- Vue (`.vue`)
- HTML (`.html`)
- Any other file type with Paraglide imports

## Troubleshooting

### "no translation files found" warning

The plugin couldn't find `.inlang/messages/` directory.

**Fix:**
- Ensure your project has a valid `.inlang/messages/` directory
- Check that `project_root` is set correctly in configuration
- Verify you have at least one `.json` file in `.inlang/messages/`

### Virtual text not appearing

1. Check if plugin is enabled:
   ```lua
   :lua print(require("paraglide.config").get_all())
   ```

2. Check current buffer has message calls:
   ```lua
   :lua print(require("paraglide").get_state())
   ```

3. Try refreshing manually:
   ```
   :ParaglideRefresh
   ```

### Locale not found

```
:ParaglideSetLocale de    " Error: locale 'de' not found
```

**Fix:** Check available locales with:

```lua
:lua print(vim.inspect(require("paraglide").get_state().available_locales))
```

Ensure you have a corresponding `.json` file in `.inlang/messages/` (e.g., `de.json`).

### Performance issues

If virtual text causes slowdown on large files:

1. Disable auto-update:
   ```lua
   require("paraglide").setup({ auto_update = false })
   ```

2. Use `:ParaglideToggle` to disable when not needed

3. Limit to specific file types:
   ```lua
   require("paraglide").setup({ filetypes = { "javascript", "svelte" } })
   ```

## Tips & Tricks

### Quick Locale Preview

Create a key binding to quickly cycle through locales:

```lua
local paraglide = require("paraglide")

local function get_locales()
  return paraglide.get_state().available_locales
end

local current_idx = 1
vim.keymap.set("n", "<leader>pn", function()
  local locales = get_locales()
  current_idx = (current_idx % #locales) + 1
  paraglide.set_locale(locales[current_idx])
end, { desc = "Next locale" })

vim.keymap.set("n", "<leader>pp", function()
  local locales = get_locales()
  current_idx = (current_idx - 2) % #locales + 1
  paraglide.set_locale(locales[current_idx])
end, { desc = "Previous locale" })
```

### Disable for Specific Buffers

```lua
local paraglide = require("paraglide")

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",  -- Don't show translations in markdown files
  callback = function()
    paraglide.toggle()  -- Toggle off
  end,
})
```

## Next Steps

- Read [DEVELOPMENT.md](./DEVELOPMENT.md) to understand the plugin architecture
- Check [README.md](./README.md) for more information
- See `test-fixture/` directory for example Paraglide projects
