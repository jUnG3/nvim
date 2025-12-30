-- lua/config/autocmds.lua

-- LspAttach: buffer-local LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    local tb = require("telescope.builtin")

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gi", vim.lsp.buf.implementation, "Implementation")
    map("n", "K",  vim.lsp.buf.hover, "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>ds", tb.lsp_document_symbols, "Doc symbols")
    map("n", "<leader>ws", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

-- Try to show signature help automatically when entering Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    pcall(vim.lsp.buf.signature_help)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function()
    vim.lsp.enable("clangd")
  end,
})

