-- Example Neovim configuration for paraglide.nvim
-- Add this to your Neovim config (e.g., ~/.config/nvim/init.lua or with lazy.nvim)

-- Using lazy.nvim
local spec = {
  "hertelp/paraglide.nvim",
  config = function()
    require("paraglide").setup({
      -- Directory containing .inlang folder (defaults to getcwd())
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
  end,
}

-- Optional: Add key bindings
-- vim.keymap.set("n", "<leader>pt", require("paraglide").toggle, { noremap = true, desc = "Toggle Paraglide" })
-- vim.keymap.set("n", "<leader>pl", function()
--   vim.ui.input({ prompt = "Locale: " }, function(locale)
--     if locale then require("paraglide").set_locale(locale) end
--   end)
-- end, { noremap = true, desc = "Set Paraglide locale" })
