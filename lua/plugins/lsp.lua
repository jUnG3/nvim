-- lua/plugins/lsp.lua

return {
  ---------------------------------------------------------------------------
  -- LSP core (clangd via new vim.lsp.config API)
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Mason: install servers
      require("mason").setup()

      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = { "clangd" },
        automatic_installation = true,
      })

      -- Capabilities for completion (shared with Java jdtls)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- New-style config: no require("lspconfig") here
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=never",
          "--fallback-style=llvm",
        },
        capabilities = capabilities,
      })

      -- Enable clangd (will start when you open C/C++ buffers)
      vim.lsp.enable("clangd")
      pcall(vim.lsp.disable, "disable")

      -- Diagnostics styling
      vim.diagnostic.config({
        signs = {
          priority = 20,
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Completion: nvim-cmp + LuaSnip
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<C-e>"]     = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Formatting: Conform (clang-format + Java via LSP)
  ---------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          c   = { "clang_format" },
          cpp = { "clang_format" },
          -- java: formatting via jdtls (LSP), so no external formatter here
        },
        format_on_save = function(bufnr)
          local ft = vim.bo[bufnr].filetype

          if ft == "c" or ft == "cpp" then
            return {
              timeout_ms = 1000,
              lsp_fallback = false,
              async = false,
            }
          end

          if ft == "java" then
            return {
              timeout_ms = 2000,
              lsp_fallback = true, -- use jdtls
              async = false,
            }
          end
        end,
        formatters = {
          clang_format = {
            condition = function(ctx)
              local found = vim.fs.find(
                { ".clang-format", "_clang-format" },
                { upward = true, path = ctx.dirname }
              )
              return not vim.tbl_isempty(found)
            end,
          },
        },
      })
    end,
  },
}
