# Architecture & Design

## Overview

paraglide.nvim is a Neovim plugin that displays Paraglide.js translation snippets as virtual text next to their usage in code. It's designed to be lightweight, fast, and zero-configuration for most use cases.

## Core Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   User's Neovim Buffer                   │
│  (JavaScript/TypeScript/Svelte/Vue/etc. code files)     │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│              paraglide.nvim Plugin                       │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Parser Module (parser.lua)                    │    │
│  │  - Loads .inlang/messages/*.json files        │    │
│  │  - Finds message calls in code via regex      │    │
│  │  - Extracts message keys                      │    │
│  └────────────────────────────────────────────────┘    │
│                   │                                      │
│                   ▼                                      │
│  ┌────────────────────────────────────────────────┐    │
│  │  Core Module (init.lua)                        │    │
│  │  - Manages plugin state (locale, enabled)     │    │
│  │  - Coordinates between modules                │    │
│  │  - Handles buffer updates                     │    │
│  │  - Manages autocmds and user commands         │    │
│  └────────────────────────────────────────────────┘    │
│                   │                                      │
│                   ▼                                      │
│  ┌────────────────────────────────────────────────┐    │
│  │  Display Module (display.lua)                  │    │
│  │  - Formats translations for display           │    │
│  │  - Creates virtual text with proper styling   │    │
│  └────────────────────────────────────────────────┘    │
│                   │                                      │
│                   ▼                                      │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│         Neovim API (Extmarks & Virtual Text)            │
│  - nvim_buf_set_extmark()                              │
│  - nvim_buf_clear_namespace()                          │
│  - nvim_create_autocmd()                               │
│  - nvim_create_user_command()                          │
└─────────────────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│            Translation Files on Disk                    │
│  .inlang/messages/                                     │
│  ├── en.json  {"greeting": "Hello {name}!", ...}       │
│  ├── de.json  {"greeting": "Hallo {name}!", ...}       │
│  └── es.json  {"greeting": "¡Hola {name}!", ...}       │
└─────────────────────────────────────────────────────────┘
```

## Module Breakdown

### 1. Core Module (`lua/paraglide/init.lua`)

**Responsibilities:**
- Plugin initialization and setup
- State management (enabled status, current locale, loaded translations)
- Buffer update orchestration
- User command handling
- Autocmd setup for real-time updates

**Key Data Structure:**
```lua
state = {
  enabled = true,                        -- Display enabled
  locale = "en",                         -- Current locale
  translations = {                       -- Loaded translations
    en = { hello = "Hello", ... },
    de = { hello = "Hallo", ... },
  },
  namespace = vim.api.nvim_create_namespace("paraglide"),
  watchers = {},                         -- File watchers
}
```

**Public API:**
- `setup(config)` - Initialize plugin
- `toggle()` - Enable/disable display
- `set_locale(locale)` - Switch language
- `refresh()` - Reload translations and update display
- `update_buffer(bufnr)` - Update specific buffer
- `clear()` - Clear all virtual text
- `get_state()` - Return current state (for debugging)

### 2. Parser Module (`lua/paraglide/parser.lua`)

**Responsibilities:**
- Load JSON translation files from `.inlang/messages/`
- Find message calls in source code using regex patterns
- Extract message keys and metadata

**Key Functions:**

**`load_translations()`**
```lua
-- Returns: { locale = { key = translation, ... }, ... }
local translations = M.load_translations()
-- Result:
-- {
--   en = { greeting = "Hello {name}!", hello_world = "Hello World!" },
--   de = { greeting = "Hallo {name}!", hello_world = "Hallo Welt!" },
-- }
```

**`find_message_calls(line)`**
```lua
-- Input: 'm.greeting({name: "John"}) and m.hello()'
-- Returns: Array of { key = "greeting", col = 1 }, { key = "hello", col = 32 }
```

**Supported Message Patterns:**
1. `m.key(...)` - Simple dot notation
2. `m.nested.key(...)` - Nested keys with dots
3. `m["key"](...)` - Bracket notation with double quotes
4. `m['key'](...)` - Bracket notation with single quotes

### 3. Display Module (`lua/paraglide/display.lua`)

**Responsibilities:**
- Format translations for display
- Create extmark virtual text
- Handle text truncation and styling

**Key Functions:**

**`format_virtual_text(translation)`**
```lua
-- Input: "Hello {name}!"
-- Output: { { "▸ Hello {name}!", "Comment" } }
-- Ready for use with nvim_buf_set_extmark()
```

### 4. Configuration Module (`lua/paraglide/config.lua`)

**Responsibilities:**
- Store default configuration
- Merge user configuration with defaults
- Provide configuration access interface
- Support nested key access with dot notation

**Default Configuration:**
```lua
{
  project_root = vim.fn.getcwd(),        -- Root directory
  default_locale = "en",                 -- Initial locale
  virtual_text = {
    enabled = true,
    prefix = "▸ ",                       -- Text prefix
    highlight_group = "Comment",         -- Highlighting
  },
  auto_update = true,                    -- Watch file changes
  filetypes = {},                        -- Empty = all types
}
```

### 5. Watcher Module (`lua/paraglide/watcher.lua`)

**Responsibilities:**
- Setup file system watchers
- Detect changes to translation files
- Debounce refresh callbacks
- Handle cleanup

**Key Features:**
- Uses `vim.loop.new_fs_event()` for efficient file watching
- Debounces rapid file changes (500ms default)
- Watches `.inlang/messages/` directory
- Triggers refresh on JSON file changes

## Data Flow

### 1. Plugin Initialization
```
setup() 
  → load config 
  → setup watchers 
  → load_translations() 
  → update all buffers
```

### 2. Buffer Update on Text Change
```
BufWritePost autocmd
  → if enabled: update_buffer()
    → find_message_calls() in each line
    → lookup translations for found keys
    → set extmarks with virtual text
```

### 3. File Change Detection
```
.inlang/messages/*.json file changes
  → watcher detects change
  → debounce 500ms
  → refresh()
    → load_translations()
    → update all visible buffers
```

### 4. Locale Switch
```
set_locale("de")
  → verify locale exists
  → update state.locale
  → refresh()
    → update_buffer() for all buffers
```

## Performance Considerations

### Message Detection
- Uses Lua regex patterns (very fast, < 1ms per line)
- Evaluates all patterns per line (safe trade-off)
- No AST parsing required (keeps Lua-only)

### Translation Loading
- Loads all locales at startup (small JSON files)
- Caches translations in memory
- Uses `vim.json.decode()` (C implementation, fast)

### Virtual Text Display
- Uses Neovim's extmarks (optimized rendering)
- Clears namespace before updating (prevents duplicates)
- Sets one extmark per message per line (minimal overhead)

### File Watching
- Debounces changes (prevents excessive updates)
- Only watches `.inlang/messages/` directory
- Lightweight libuv event loop integration

## Extension Points

### Adding New Message Patterns
Edit `parser.lua` `find_message_calls()`:
```lua
local patterns = {
  'm%.([%w_%.]+)%s*%(',              -- Existing
  'YOUR_NEW_PATTERN',                -- Add here
}
```

### Custom Virtual Text Formatting
Override in `display.lua` `format_virtual_text()`:
```lua
function M.format_virtual_text(translation)
  -- Custom formatting logic
  return { { formatted_text, highlight } }
end
```

### Custom Message Detection Strategy
Create new module and integrate in `init.lua`:
```lua
local custom_parser = require("paraglide.custom_parser")
local calls = custom_parser.find_message_calls(line)
```

## Limitations & Trade-offs

### Pure Lua Implementation
✅ **Pros:**
- No build requirements
- First-class Neovim integration
- Simple distribution and installation
- Easy to extend

❌ **Cons:**
- Regex-based parsing (not AST-based)
- Slower on very large files (1000+ calls/file)
- Can't handle very complex code patterns

### No Rust Backend (Yet)
While this is pure Lua for simplicity, a future Rust version could:
- Use proper AST parsing for 100% accuracy
- Handle dynamic imports and complex patterns
- Achieve sub-millisecond parsing on huge files

### Virtual Text Only
✅ **Focus:**
- Display only (no editing)
- Consistent with LSP inlay hints
- Lower complexity, fewer bugs

❌ **Not Included:**
- Translation editing (use Fink editor or Sherlock)
- Inline parameter resolution
- Translation lookup from message body

## Integration with Ecosystem

### Paraglide.js Ecosystem
- **Sherlock VSCode Extension** - Complementary tool for editing translations
- **Fink Editor** - Web UI for translation management
- **CLI** - Automation and machine translation

### Neovim Ecosystem
- Works with any plugin manager (lazy.nvim, packer, vim-plug)
- Compatible with LSP plugins (doesn't conflict)
- Works alongside other virtual text plugins
- Uses standard Neovim APIs (no hack dependencies)

## Future Enhancements

### Potential Features
1. **Rust backend** - For improved performance on large codebases
2. **Parameter interpolation** - Show actual values in virtual text
3. **Translation search** - Find uses of specific translations
4. **Missing translation detection** - Highlight untranslated keys
5. **Integration with Sherlock** - Unified translation editing workflow

### Backward Compatibility
- All future changes will maintain the current Lua API
- Configuration options may be extended but not changed
- Core functionality (display translations) will remain stable

## Testing Strategy

### Unit Tests
- Parser pattern matching (see `tests/test_parser.lua`)
- Configuration loading and access
- Translation file parsing

### Integration Tests
- Full plugin workflow in test fixture
- Multiple locale switching
- File watching triggers
- Buffer updates

### Manual Testing
- Various file types (JS, TS, Svelte, Vue, HTML)
- Large files with many message calls
- Different configuration options
- Real Paraglide.js projects

## Code Quality

### Principles
- **Simplicity** - Favor simple, readable code over clever optimizations
- **Robustness** - Gracefully handle errors (missing files, invalid JSON, etc.)
- **Documentation** - Every function has JSDoc comments
- **Testing** - Critical paths have tests

### Style Guide
- Lua 5.1 compatible (for LuaJIT compatibility)
- 2-space indentation
- Descriptive variable names
- Comments for non-obvious logic

---

For more details, see [DEVELOPMENT.md](./DEVELOPMENT.md) and [QUICKSTART.md](./QUICKSTART.md).
