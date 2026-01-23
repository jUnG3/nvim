-- lua/plugins/treesitter.lua
return {
  -- Core Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" }, -- defer load
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.schedule(function()
          vim.notify("[treesitter] nvim-treesitter not available yet", vim.log.levels.WARN)
        end)
        return
      end
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
        -- You can keep textobjects config here; the module will apply once the extension loads
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

  -- Treesitter Textobjects (load only after core is present)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },                 -- lazy-load
    dependencies = { "nvim-treesitter/nvim-treesitter" },    -- ensure order
    cond = function()                                        -- belt-and-suspenders
      return package.loaded["nvim-treesitter.configs"] ~= nil
    end,
  },
}
