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
      local java_home = "/nix/store/65qpdkc33j5wqzxvz8c23zhgms8hl35y-openjdk-21.0.9+10/lib/openjdk"

      -- make sure `java` resolves to the nix one
      vim.env.JAVA_HOME = java_home
      vim.env.PATH = java_home .. "/bin:" .. (vim.env.PATH or "")

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

      vim.lsp.enable("jdtls")
    end,
  },
}
