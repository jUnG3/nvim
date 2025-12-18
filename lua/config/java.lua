-- lua/config/java.lua

local M = {}

local function get_jdtls()
  local ok, jdtls = pcall(require, "jdtls")
  if not ok then
    vim.notify("[jdtls] not installed. Run :MasonInstall jdtls", vim.log.levels.ERROR)
    return nil
  end
  return jdtls
end

function M.setup_java_lsp()
  local jdtls = get_jdtls()
  if not jdtls then
    return
  end

  local mason_path = vim.fn.stdpath("data") .. "/mason"
  local jdtls_install = mason_path .. "/packages/jdtls"

  if vim.fn.isdirectory(jdtls_install) == 0 then
    vim.notify("[jdtls] not installed in Mason. Run :MasonInstall jdtls", vim.log.levels.ERROR)
    return
  end

  local launcher = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher == "" then
    vim.notify("[jdtls] Launcher JAR not found", vim.log.levels.ERROR)
    return
  end

  local config_os
  if vim.fn.has("mac") == 1 then
    config_os = "config_mac"
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    config_os = "config_win"
  else
    config_os = "config_linux"
  end

  local root_markers = { "pom.xml", "build.gradle", "settings.gradle", ".git", "mvnw", "gradlew" }
  local root_dir = jdtls.setup.find_root(root_markers) or vim.fn.getcwd()

  local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/"
    .. vim.fn.fnamemodify(root_dir, ":p:h:t")

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local lombok = vim.fn.stdpath("data")
    .. "/mason/packages/jdtls/lombok.jar"

  local cmd = {
    "java",
    "-javaagent:" .. lombok,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher,
    "-configuration", jdtls_install .. "/" .. config_os,
    "-data", workspace_dir,
  }

  local config = {
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    settings = {
      java = {
        format = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
          },
        },
        contentProvider = { preferred = "fernflower" },
      },
    },
    init_options = {
      bundles = {},
    },
  }

  jdtls.start_or_attach(config)

  -- Java-specific extras (DAP, commands, keymaps)
  jdtls.setup_dap({ hotcodereplace = "auto" })
  jdtls.setup.add_commands()

  local bufnr = vim.api.nvim_get_current_buf()
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "<leader>oi", jdtls.organize_imports, "Java: organize imports")
  map("n", "<leader>ev", jdtls.extract_variable, "Java: extract variable")
  map("v", "<leader>ev", function()
    jdtls.extract_variable(true)
  end, "Java: extract variable (visual)")

  map("v", "<leader>em", function()
    jdtls.extract_method(true)
  end, "Java: extract method")
end

-- Autocmd to start jdtls for Java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    M.setup_java_lsp()
  end,
})

return M
