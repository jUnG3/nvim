return {
  -- YAML Language Server
  {
    "neovim/nvim-lspconfig",
    optional = true, -- in case you already load it elsewhere
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = {
          yaml = {
            validate = true,
            hover = true,
            completion = true,
		filetypes = { "yaml", "yml" },
            -- Pull lots of common schemas automatically
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },

            -- Spring Boot: treat application*.yml as Spring Boot config
            schemas = {
              ["https://json.schemastore.org/spring-boot-application.json"] = {
                "application.yml",
                "application.yaml",
                "application-*.yml",
                "application-*.yaml",
                "bootstrap.yml",
                "bootstrap.yaml",
              },
            },
          },
        },
      })

      vim.lsp.enable("yamlls")
    end,
  },
}

