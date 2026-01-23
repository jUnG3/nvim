-- lua/plugins/telescope.lua

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-v>"] = actions.select_vertical,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-t>"] = actions.select_tab,
            },
            n = {
              ["v"] = actions.select_vertical,
              ["s"] = actions.select_horizontal,
              ["t"] = actions.select_tab,
            },
          },
	  vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",         -- include dotfiles
            "--glob", "!.git/", -- but keep .git excluded
          },
        },
	pickers = {
          find_files = {
            hidden = true,          -- show dotfiles
            no_ignore = treu,      -- set true if you want to ignore .gitignore
            no_ignore_parent = false,
            -- Alternatively use fd (faster) if installed:
            -- find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
          },
        },
      })
    end,
  },
}
