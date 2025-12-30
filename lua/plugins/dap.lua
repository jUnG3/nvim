return {
  {
    "williamboman/mason.nvim",
    opts = {}, -- or config = true
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason").setup()
      require("mason-nvim-dap").setup({
        automatic_setup = true,
      })
    end,
  },
}

