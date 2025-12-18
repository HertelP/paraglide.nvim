" Paraglide.nvim - Display Paraglide.js translations in Neovim
"
" This plugin requires Neovim 0.7.0+

if exists('g:loaded_paraglide')
  finish
endif
let g:loaded_paraglide = 1

" Set default configuration
if !exists('g:paraglide_config')
  let g:paraglide_config = {}
endif
