-- lua/config/options.lua

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.updatetime = 200
opt.timeoutlen = 350
opt.completeopt = "menu,menuone,noselect"
opt.scrolloff = 6
opt.splitbelow = true
opt.splitright = true

-- GUI font / ligatures (Neovide, Goneovim, etc.)
if vim.fn.has("gui_running") == 1 or vim.g.neovide or vim.g.gnvim then
  -- Adjust as you like (FiraMono vs FiraCode)
  vim.o.guifont = "FiraMono Nerd Font:h12"
end
