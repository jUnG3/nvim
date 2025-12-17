local telescope_meson = require "config.meson_telescope"
-- lua/config/keymaps.lua

local map = vim.keymap.set

------------------------------------------------------------
-- 1. Colemak-DH basic cursor movement
------------------------------------------------------------
map({ "n", "v", "o" }, "n", "h", { desc = "Left" })
map({ "n", "v", "o" }, "e", "j", { desc = "Down" })
map({ "n", "v", "o" }, "i", "k", { desc = "Up" })
map({ "n", "v", "o" }, "o", "l", { desc = "Right" })

-- Wrapped line movement
map("n", "ge", "gj", { desc = "Down (wrapped line)" })
map("n", "gi", "gk", { desc = "Up (wrapped line)" })

-- Search next / prev using <leader>n / <leader>N
map("n", "<leader>n", function()
  vim.cmd("normal! n")
end, { desc = "Search next" })

map("n", "<leader>N", function()
  vim.cmd("normal! N")
end, { desc = "Search previous" })

------------------------------------------------------------
-- 2. Insert mode helpers
------------------------------------------------------------
map("n", "h", "i", { desc = "Insert at cursor" })
map("n", "H", "I", { desc = "Insert at line start" })

-- Open line below / above (your chosen l / L mapping)
map("n", "l", "o", { desc = "Open new line below" })
map("n", "L", "O", { desc = "Open new line above" })

------------------------------------------------------------
-- 3. Window management
------------------------------------------------------------
map("n", "<C-n>", "<C-w>h", { desc = "Window left" })
map("n", "<C-e>", "<C-w>j", { desc = "Window down" })
map("n", "<C-i>", "<C-w>k", { desc = "Window up" })
map("n", "<C-o>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Close split" })

------------------------------------------------------------
-- 4. Buffers / Files / Save / Quit
------------------------------------------------------------
map("n", "<leader>bn", ":bnext<CR>",     { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":bdelete<CR>",   { desc = "Delete buffer" })

map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

------------------------------------------------------------
-- 5. Telescope
------------------------------------------------------------
local tb_ok, tb = pcall(require, "telescope.builtin")
if tb_ok then
  map("n", "<leader>ff", tb.find_files, { desc = "Find files" })
  map("n", "<leader>fg", tb.live_grep,  { desc = "Live grep" })
  map("n", "<leader>fb", tb.buffers,    { desc = "Buffers" })
  map("n", "<leader>fh", tb.help_tags,  { desc = "Help tags" })

  -- Extra LSP helpers
  map("n", "<leader>ds", tb.lsp_document_symbols,  { desc = "Document symbols" })
  map("n", "<leader>ws", tb.lsp_workspace_symbols, { desc = "Workspace symbols" })
  map("n", "<leader>xr", function()
    tb.lsp_references({})
  end, { desc = "Telescope: LSP references" })
 
  -- Gradle list all tasks
  vim.keymap.set("n", "<leader>cgt", function()
    require("config.gradle_telescope").pick_gradle_tasks()
  end, { desc = "Gradle: pick and run tasks" })
  
  -- Buffers
  map("n", "<leader>bb", function()
    tb.buffers({ sort_mru = true, show_all_buffers = true })
  end, { desc = "Telescope: list buffers" })

  -- workspace (project) diagnostics
  map("n", "<leader>wx", function()
    tb.diagnostics({})
  end, { desc = "Telescope: workspace diagnostics" })

  -- current file (buffer) diagnostics
  map("n", "<leader>dx", function()
    tb.diagnostics({ bufnr = 0 })
  end, { desc = "Telescope: buffer diagnostics" })

  -- Meson list compile targets
  map("n", "<leader>cmt", telescope_meson.open_meson_picker, { desc = "Telescope: Meson (pick build dir + action)" })

end

------------------------------------------------------------
-- 7. LSP extras
------------------------------------------------------------
map("n", "gV", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Definition in vsplit" })

map("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Manual format: uses Conform / LSP depending on ft
map("n", "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })

------------------------------------------------------------
-- 8. DAP (debugger) keymaps
------------------------------------------------------------
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "DAP Continue" })

map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "DAP Step over" })

map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "DAP Step into" })

map("n", "<F12>", function()
  require("dap").step_out()
end, { desc = "DAP Step out" })

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "DAP Toggle breakpoint" })

map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP Conditional breakpoint" })

map("n", "<leader>dr", function()
  require("dap").repl.open()
end, { desc = "DAP REPL" })

map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "DAP UI" })

------------------------------------------------------------
-- 9. Git (Neogit + Diffview)
------------------------------------------------------------
map("n", "<leader>gg", function()
  require("neogit").open()
end, { desc = "Git: Neogit" })

map("n", "<leader>gd", function()
  require("diffview").open()
end, { desc = "Git: Diffview (current)" })

map("n", "<leader>gD", function()
  local rev = vim.fn.input("Diff against revision: ")
  if rev ~= "" then
    require("diffview").open(rev)
  end
end, { desc = "Git: Diffview (revision)" })

map("n", "<leader>gh", function()
  require("diffview").file_history()
end, { desc = "Git: file history" })

map("n", "<leader>gc", ":Neogit commit<CR>", { desc = "Git: commit" })
map("n", "<leader>gP", ":Neogit push<CR>",   { desc = "Git: push" })
map("n", "<leader>gF", ":Neogit pull<CR>",   { desc = "Git: pull" })
