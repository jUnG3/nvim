-- lua/plugins/java.lua
return {
  {
    "nvim-java/nvim-java",
    dependencies = {
      "mfussenegger/nvim-dap",
      "MunifTanjim/nui.nvim",
      "JavaHello/spring-boot.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Lombok agent
      local lombok = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
      if vim.fn.filereadable(lombok) == 1 then
        local agent = "-javaagent:" .. lombok
        local cur = vim.env.JAVA_TOOL_OPTIONS or ""
        if not cur:find(agent, 1, true) then
          vim.env.JAVA_TOOL_OPTIONS = (cur ~= "" and (cur .. " ") or "") .. agent
        end
      end

      require("java").setup({
        jdk = {
          auto_install = false, -- 👈 stop downloading OpenJDK (critical)
        },
      })

      vim.lsp.config("jdtls", {
				filetypes = { "java" },
			})
      vim.api.nvim_create_autocmd("FileType", {
    pattern = { "java" },
    callback = function()
      vim.lsp.enable("jdtls")
    end,
  })
    end,
  },
}
