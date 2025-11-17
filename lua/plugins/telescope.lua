-- lua/plugins/telescope.lua

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
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
        },
      })
    end,
  },
}
