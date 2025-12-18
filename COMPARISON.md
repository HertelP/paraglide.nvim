# Comparison: paraglide.nvim vs js-i18n.nvim

## Quick Answer
They are **similar but serve different purposes**. Your `js-i18n.nvim` is more feature-rich and production-ready, while `paraglide.nvim` is specialized for Paraglide.js only.

---

## Side-by-Side Comparison

| Feature | paraglide.nvim | js-i18n.nvim | Winner |
|---------|---|---|---|
| **Primary Purpose** | Paraglide.js only | i18next, react-i18next, next-intl | js-i18n (more libraries) |
| **Display Translations** | ✓ Virtual text at EOL | ✓ Virtual text at EOL | Tie |
| **Edit Translations** | ✗ Display only | ✓ Full editing support | js-i18n |
| **Multiple Locales** | ✓ Switch with command | ✓ Switch with command | Tie |
| **Auto-update Files** | ✓ File watching | ✓ File watching | Tie |
| **Jump to Definition** | ✗ | ✓ | js-i18n |
| **Error Detection** | ✗ | ✓ Missing translations | js-i18n |
| **Hover Info** | ✗ | ✓ Show translations for each lang | js-i18n |
| **Key Completion** | ✗ | ✓ Autocomplete keys | js-i18n |
| **Tree-sitter** | ✗ Regex-based | ✓ Uses Tree-sitter | js-i18n |
| **Code Quality** | Clean, modular | Production-tested | js-i18n |
| **Documentation** | Extensive (7 guides) | Good | paraglide (more thorough) |
| **Lines of Code** | ~430 | ~2,000+ (more features) | Both solid |
| **Dependencies** | None (pure Lua) | nvim-lspconfig, treesitter, plenary | paraglide (lightweight) |
| **Neovim Version** | 0.7.0+ | 0.10.0+ | paraglide (broader support) |

---

## Feature Breakdown

### Core Functionality (SIMILAR)

Both plugins:
- Display translations as virtual text
- Support multiple locales
- Watch for file changes
- Integrate with Neovim commands
- Use JSON-based translation files

### Where js-i18n.nvim EXCELS (DIFFERENT)

1. **Translation Editing**
   - Edit translations directly in code
   - Add new translations on demand
   - Uses `jq` for JSON manipulation

2. **Error Detection**
   - Diagnostic: Show missing translations
   - Highlights untranslated keys
   - Severity warnings

3. **Advanced Navigation**
   - Jump to definition of translation files
   - Hover to see all language versions
   - Go to translation source

4. **Code Intelligence**
   - Key completion/autocomplete
   - Better AST parsing with Tree-sitter
   - Language detection per file

5. **Multiple Libraries**
   - i18next
   - react-i18next
   - next-intl
   - Monorepo support

### Where paraglide.nvim IS BETTER

1. **Simplicity**
   - Focused on one library (Paraglide.js)
   - Pure Lua, no external tools needed
   - Smaller, easier to understand/modify

2. **Documentation**
   - 7 comprehensive guides (1,600+ lines)
   - Architecture documentation
   - Development guide included

3. **Broad Compatibility**
   - Works with Neovim 0.7.0+
   - vs js-i18n's 0.10.0+

4. **No External Dependencies**
   - Pure Lua only
   - js-i18n requires: nvim-lspconfig, treesitter, plenary, jq

---

## Architecture Comparison

### paraglide.nvim
```
Regex Pattern Matching
    ↓
JSON File Loading
    ↓
Virtual Text Display (extmarks)
    ↓
File Watching (debounced)
```

**Pros:** Simple, fast, no dependencies  
**Cons:** Limited to regex patterns, can't do complex parsing

### js-i18n.nvim
```
Tree-sitter AST Parsing
    ↓
LSP Integration
    ↓
Language Server Protocol
    ↓
Virtual Text, Diagnostics, Hover, Completion
    ↓
File Operations (jq for editing)
```

**Pros:** Comprehensive, multi-library support, advanced features  
**Cons:** More complex, more dependencies, requires newer Neovim

---

## Use Cases

### Choose paraglide.nvim if:
- ✓ You use Paraglide.js exclusively
- ✓ You want minimal dependencies
- ✓ You use older Neovim (0.7.0+)
- ✓ You only need to VIEW translations (not edit)
- ✓ You want to understand/modify the code easily
- ✓ You need excellent documentation

### Choose js-i18n.nvim if:
- ✓ You use i18next, react-i18next, or next-intl
- ✓ You need to EDIT translations in the editor
- ✓ You want error detection for missing translations
- ✓ You use Neovim 0.10.0+
- ✓ You need key completion
- ✓ You work with monorepos
- ✓ You need production-grade features

---

## Command Comparison

### paraglide.nvim
```
:ParaglideToggle              # On/off
:ParaglideSetLocale <lang>    # Switch language
:ParaglideRefresh             # Reload
```

### js-i18n.nvim
```
:I18nSetLang [lang]                 # Set language
:I18nEditTranslation [lang]         # Edit translation
:I18nVirtualTextEnable/Disable      # Virtual text
:I18nDiagnosticEnable/Disable       # Diagnostics
:I18nCopyKey                        # Copy key
:I18nVirtualTextToggle              # Toggle VT
:I18nDiagnosticToggle               # Toggle diag
```

js-i18n has more commands (editing, diagnostics).

---

## Technical Differences

### Message Detection
- **paraglide.nvim**: Regex patterns (3 patterns for i18next-style calls)
- **js-i18n.nvim**: Tree-sitter queries (proper AST parsing)

### File Operations
- **paraglide.nvim**: Pure Lua JSON reading/writing
- **js-i18n.nvim**: Uses `jq` tool for complex JSON edits

### Dependencies
- **paraglide.nvim**: Zero (pure Lua)
- **js-i18n.nvim**: nvim-lspconfig, nvim-treesitter, plenary.nvim, jq (system tool)

### Performance
- **paraglide.nvim**: Very fast (regex, simple logic)
- **js-i18n.nvim**: Slightly slower (LSP, Tree-sitter parsing)

---

## Conclusion

| Aspect | Winner |
|--------|--------|
| **For Paraglide.js users** | paraglide.nvim (specialized) |
| **For i18next users** | js-i18n.nvim (specialized) |
| **For multiple libraries** | js-i18n.nvim |
| **For simplicity** | paraglide.nvim |
| **For features** | js-i18n.nvim |
| **For documentation** | paraglide.nvim |
| **For broad support** | paraglide.nvim (0.7.0+) |
| **For production use** | js-i18n.nvim (more mature) |

---

## Next Steps

Since you already have `js-i18n.nvim`, paraglide.nvim serves as:
1. A **complementary tool** for Paraglide.js projects
2. A **learning resource** - simpler codebase to understand plugin development
3. An **alternative** if you prefer lightweight plugins

You could:
- **Use js-i18n.nvim** for your main projects (more features)
- **Use paraglide.nvim** if/when you switch to Paraglide.js
- **Learn from paraglide.nvim** code for plugin development
- **Contribute** features from paraglide.nvim to js-i18n.nvim if useful
