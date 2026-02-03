return {
  {
    -- Use a plugin “carrier” so Lazy runs this config; lspconfig is not required
    "nvim-lua/plenary.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function is_win()
        return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
      end

      local function project_root(bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local found = vim.fs.find(
          { ".venv", "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", "Pipfile", ".git" },
          { path = fname, upward = true }
        )[1]
        local dir = found and vim.fs.dirname(found) or vim.loop.cwd()
        return dir
      end

      local function venv_bin(root)
        local sep = package.config:sub(1,1)
        local venv = root .. sep .. ".venv"
        local bin  = is_win() and (venv .. sep .. "Scripts" .. sep) or (venv .. sep .. "bin" .. sep)
        return venv, bin
      end

      local function exe(path) return vim.fn.executable(path) == 1 and path or nil end

      local function start_python(bufnr)
        local root = project_root(bufnr)
        local venv, bin = venv_bin(root)

        local pyright = exe(bin .. "pyright-langserver")
        local pylsp   = exe(bin .. "pylsp")
        local ruff    = exe(bin .. "ruff-lsp")

        if pyright then
          vim.notify(string.format("[Python] Starting pyright from %s", bin))
          vim.lsp.start({
            name = "pyright",
            cmd = { pyright, "--stdio" },
            root_dir = root,
            capabilities = capabilities,
            filetypes = { "python" },
          })
        elseif pylsp then
          vim.notify(string.format("[Python] Starting pylsp from %s", bin))
          vim.lsp.start({
            name = "pylsp",
            cmd = { pylsp },
            root_dir = root,
            capabilities = capabilities,
            filetypes = { "python" },
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = { enabled = false },
                  mccabe      = { enabled = false },
                  pyflakes    = { enabled = false },
                  jedi_completion = { enabled = true, fuzzy = true },
                  jedi_hover      = { enabled = true },
                },
              },
            },
          })
        else
          vim.notify(string.format("[Python] No server in .venv at %s. Install pyright or pylsp there.", venv), vim.log.levels.WARN)
        end

        if ruff then
          vim.lsp.start({
            name = "ruff_lsp",
            cmd = { ruff },
            root_dir = root,
            capabilities = capabilities,
            filetypes = { "python" },
          })
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function(args) start_python(args.buf) end,
      })
    end,
  },
}
