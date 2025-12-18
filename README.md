# paraglide.nvim

A Neovim plugin that displays Paraglide.js translation snippets as virtual text next to their usage in your code.

## Features

- Display translated text as virtual text at end of line
- Support for all file types where Paraglide messages are used (JS, TS, JSX, TSX, Svelte, Vue, etc.)
- Single locale view at a time with easy locale switching
- Automatic translation file detection and watching
- Real-time updates when translation files change
- Configurable virtual text styling and positioning

## Installation

Using `lazy.nvim`:

```lua
{
  "hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup({
      -- Configuration options
    })
  end,
}
```

Using `packer.nvim`:

```lua
use {
  "hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup({})
  end,
}
```

## Configuration

```lua
require("paraglide").setup({
  -- Directory containing .inlang folder
  project_root = vim.fn.getcwd(),
  
  -- Default locale to display
  default_locale = "en",
  
  -- Virtual text styling
  virtual_text = {
    enabled = true,
    prefix = "▸ ",           -- prefix before translation
    highlight_group = "Comment",  -- highlight group for virtual text
  },
  
  -- Auto-update when files change
  auto_update = true,
  
  -- File types to enable plugin for (empty = all)
  filetypes = {},
})
```

## Usage

### Commands

- `:ParaglideToggle` - Toggle virtual text display on/off
- `:ParaglideSetLocale <locale>` - Switch to a different locale
- `:ParaglideRefresh` - Manually refresh translations

### Key Bindings

None are set by default. You can add them in your config:

```lua
local paraglide = require("paraglide")

vim.keymap.set("n", "<leader>pt", paraglide.toggle, { noremap = true })
vim.keymap.set("n", "<leader>pl", function()
  vim.ui.input({ prompt = "Locale: " }, function(locale)
    if locale then paraglide.set_locale(locale) end
  end)
end, { noremap = true })
```

## How it Works

1. Scans `.inlang/messages/{locale}.json` files for your project
2. Detects Paraglide message calls in your code: `m.messageKey(...)`, `m["message.key"](...)`
3. Displays the translated text as virtual text at end of line
4. Updates automatically when translation files change

## Requirements

- Neovim 0.7.0 or later
- Paraglide.js project with `.inlang/messages/` directory

## License

MIT
