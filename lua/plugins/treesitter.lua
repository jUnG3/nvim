return {
  -- Core Treesitter: on rtp from the start
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    priority = 1000,
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.config")
      configs.setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "java", "python" },
        highlight = { enable = true },
        indent    = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "gnn",
            node_incremental  = "gni",
            scope_incremental = "gns",
            node_decremental  = "gnd",
          },
        },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]p"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[p"] = "@parameter.inner",
            },
          },
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  -- Textobjects: load only after a file is opened; ensure core is present
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "BufReadPost",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
