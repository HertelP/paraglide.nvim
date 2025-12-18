# Using paraglide.nvim with nixvim

This document explains how to use paraglide.nvim in your nixvim configuration.

## Basic Usage

Add the following to your nixvim configuration:

```nix
{
  programs.nixvim = {
    plugins.paraglide = {
      enable = true;
      settings = {
        project_root = "vim.fn.getcwd()";
        default_locale = "en";
        virtual_text = {
          enabled = true;
          prefix = "▸ ";
          highlight_group = "Comment";
        };
        auto_update = true;
        filetypes = [ ];
      };
    };
  };
}
```

## Configuration Options

### `enable` (boolean, default: false)
Enable the paraglide.nvim plugin.

### `settings` (attribute set)

#### `project_root` (string, default: "vim.fn.getcwd()")
Directory containing the `.inlang` folder with translation files.

#### `default_locale` (string, default: "en")
The default locale to display translations for.

#### `virtual_text` (attribute set)
Configuration for virtual text display.

- `enabled` (boolean, default: true): Enable virtual text display
- `prefix` (string, default: "▸ "): Prefix before each translation
- `highlight_group` (string, default: "Comment"): Highlight group for virtual text

#### `auto_update` (boolean, default: true)
Automatically update translations when files change.

#### `filetypes` (list of strings, default: [])
File types to enable the plugin for. Empty list means all file types.

## Complete Example

```nix
{
  programs.nixvim = {
    plugins.paraglide = {
      enable = true;
      settings = {
        default_locale = "de";
        virtual_text = {
          enabled = true;
          prefix = "→ ";
          highlight_group = "DiagnosticHint";
        };
        auto_update = true;
        filetypes = [ "javascript" "typescript" "svelte" ];
      };
    };
  };
}
```

## Available Commands

Once enabled, the following commands are available:

- `:ParaglideToggle` - Toggle virtual text display on/off
- `:ParaglideSetLocale <locale>` - Switch to a different locale
- `:ParaglideRefresh` - Manually refresh translations

## Requirements

- Neovim 0.7.0 or later
- A Paraglide.js project with `.inlang/messages/` directory containing locale JSON files
