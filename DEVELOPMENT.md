# Development Guide for paraglide.nvim

## Project Structure

```
paraglide.nvim/
├── lua/paraglide/
│   ├── init.lua          # Main plugin entry point
│   ├── parser.lua        # Parse translations and find message calls
│   ├── display.lua       # Format and display virtual text
│   ├── config.lua        # Configuration management
│   └── watcher.lua       # File watching for auto-updates
├── plugin/
│   └── paraglide.vim     # Plugin initialization (Vimscript)
├── tests/
│   └── test_parser.lua   # Tests for parser module
├── test-fixture/         # Sample Paraglide project for testing
│   ├── .inlang/messages/
│   │   ├── en.json
│   │   ├── de.json
│   │   └── es.json
│   └── *.js/.svelte      # Example source files
└── README.md
```

## Running Tests

### Test Parser Module

```bash
cd /home/hertelp/paraglide.nvim
nvim --headless -c "luafile tests/test_parser.lua" -c "quit"
```

### Test Plugin in Neovim

1. Start Neovim with the test fixture as the working directory:
```bash
cd /home/hertelp/paraglide.nvim/test-fixture
nvim
```

2. Install the plugin locally for testing. If using lazy.nvim, add:
```lua
{
  dir = "/home/hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup()
  end,
}
```

3. Open one of the example files (`example.js` or `example.svelte`)

4. Use the plugin commands:
```
:ParaglideToggle       " Toggle virtual text on/off
:ParaglideSetLocale de " Switch to German
:ParaglideSetLocale es " Switch to Spanish
:ParaglideRefresh      " Manually refresh translations
```

## Module Overview

### `init.lua` - Main Plugin
- Manages plugin state (enabled, current locale, translations)
- Handles buffer updates with virtual text
- Sets up autocmds for BufEnter and BufWritePost
- Exposes user commands and public API

### `parser.lua` - Translation Loading & Detection
- `load_translations()` - Scans `.inlang/messages/*.json` and loads translations
- `find_message_calls()` - Uses regex to find message calls in code lines
- Supports multiple patterns:
  - `m.key()`
  - `m["key"]()`
  - `m['key']()`

### `display.lua` - Virtual Text Formatting
- `format_virtual_text()` - Converts translation to virtual text format
- Handles text truncation for long translations
- Manages highlighting

### `config.lua` - Configuration
- Stores default and user configuration
- Supports nested key access with dot notation
- Methods: `setup()`, `get()`, `set()`, `get_all()`

### `watcher.lua` - File Watching
- Sets up file system watchers for `.inlang/messages/`
- Debounces callbacks to avoid excessive updates
- Auto-refreshes translations when files change

## Key Patterns & APIs Used

### Neovim API
- `nvim_buf_set_extmark()` - Add virtual text to buffer
- `nvim_buf_clear_namespace()` - Clear virtual text
- `nvim_create_namespace()` - Create namespace for marks
- `nvim_create_autocmd()` - Watch for buffer events
- `nvim_create_user_command()` - Register user commands

### Lua File I/O
- `io.open()` - Read JSON files
- `vim.json.decode()` - Parse JSON
- `vim.loop.fs_scandir()` - Scan directories
- `vim.loop.new_fs_event()` - Watch file changes

## Common Issues & Debugging

### Plugin not loading?
```lua
" Check if plugin is loaded
:echo get(g:, 'loaded_paraglide', 0)
```

### No translations found?
```lua
" Check configuration
:lua print(vim.inspect(require("paraglide.config").get_all()))

" Check detected locales
:lua print(vim.inspect(require("paraglide").get_state()))
```

### Virtual text not showing?
1. Check if plugin is enabled: `:ParaglideToggle`
2. Check current buffer has message calls
3. Check if current locale has translations for detected keys

## Extending the Plugin

### Adding new patterns to message detection
Edit `parser.lua` in `find_message_calls()`:
```lua
local patterns = {
  'b[m]%.([%w_]+)%s*%(',         -- m.key(
  'b[m]%[%"([^%"]+)%"%]%s*%(',   -- m["key"](
  -- Add more patterns here
}
```

### Customizing virtual text appearance
Edit `config.lua` defaults:
```lua
virtual_text = {
  prefix = "▸ ",                 -- Change prefix
  highlight_group = "Comment",   -- Change highlight
},
```

### Adding support for additional locales
The plugin automatically detects all `.json` files in `.inlang/messages/`.
Just add new JSON files and they'll be automatically available.

## Testing Checklist

- [ ] Plugin loads without errors
- [ ] `load_translations()` finds all locale files
- [ ] `find_message_calls()` detects message calls in JavaScript
- [ ] `find_message_calls()` detects message calls in Svelte
- [ ] Virtual text appears for detected messages
- [ ] `:ParaglideSetLocale` switches between languages
- [ ] `:ParaglideToggle` enables/disables virtual text
- [ ] `:ParaglideRefresh` updates manually
- [ ] File watching updates translations on save
- [ ] Plugin doesn't crash with missing translation files
- [ ] Plugin works with various code patterns (JSX, nested calls, etc.)
