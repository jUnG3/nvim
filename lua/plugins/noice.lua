-- lua/plugins/noice.lua
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      presets = {
	lsp_doc_border = true
      }
    },
    config = function()
      require("config.noice").setup()
    end,
  },
}
