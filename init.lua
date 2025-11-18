-- ~/.config/nvim/init.lua

-- Leader keys must be set before plugins/keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core settings
require("config.options")

-- Bootstrap plugin manager and plugins
require("config.lazy")

-- Keymaps and autocmds (after lazy so plugins are on 'runtimepath')
require("config.keymaps")
require("config.autocmds")
require("config.java")
require("config.plantuml")
