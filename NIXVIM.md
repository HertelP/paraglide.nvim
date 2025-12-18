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
Project root directory. Should be set to the root of your Paraglide.js project.

#### `messages_dir` (string, default: nil)
Path to the messages directory relative to `project_root`. If not set, the plugin will auto-detect `.inlang/messages` or `messages/` directories.

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
