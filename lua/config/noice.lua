-- lua/config/noice.lua
local M = {}

function M.setup()
  -- Use nvim-notify as the notification backend if available
  local ok_notify, notify = pcall(require, "notify")
  if ok_notify then
    vim.notify = notify
    notify.setup({
      stages = "fade_in_slide_out",
      render = "default",
      timeout = 2000,
      background_colour = "#000000",
    })
  end

  local ok_noice, noice = pcall(require, "noice")
  if not ok_noice then
    vim.schedule(function()
      vim.notify("[Noice] not available", vim.log.levels.ERROR)
    end)
    return
  end

  noice.setup({
    notify = { enabled = true },
    lsp = {
      progress = { enabled = true },   -- show LSP indexing/build progress
      message  = { enabled = true },   -- route LSP messages through Noice
      hover    = { enabled = true },
      signature= { enabled = true },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      lsp_doc_border = true,           -- borders around hover/signature
      command_palette = false,
      long_message_to_split = true,
    },
    routes = {
      -- Quiet down trivial messages
      { filter = { event = "msg_show", kind = "wmsg" },  opts = { skip = true } },
      { filter = { event = "msg_show", kind = "echo" },  opts = { skip = true } },
      { filter = { event = "notify", find = "written" }, opts = { skip = true } },
      -- Keep LSP progress visible (tune if too chatty)
      { filter = { event = "lsp", kind = "progress" },   opts = { skip = false } },
    },
    views = {
      cmdline = { border = { style = "rounded" } },
      popupmenu = { border = { style = "rounded" } },
      mini = { timeout = 2000 },
    },
  })

  -- Handy Noice keymaps
  vim.keymap.set("n", "<leader>nh", function() require("noice").cmd("history") end,  { desc = "Noice: history" })
  vim.keymap.set("n", "<leader>nm", function() require("noice").cmd("messages") end, { desc = "Noice: messages" })
  vim.keymap.set("n", "<leader>nl", function() require("noice").cmd("last") end,     { desc = "Noice: last message" })
  vim.keymap.set("n", "<leader>nd", function() require("noice").cmd("dismiss") end,  { desc = "Noice: dismiss"})

  -- Optional: small LSP lifecycle notifications
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        vim.schedule(function()
          vim.notify(string.format("[LSP] Attached: %s", client.name))
        end)
      end
    end,
  })
  vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        vim.schedule(function()
          vim.notify(string.format("[LSP] Detached: %s", client.name), vim.log.levels.WARN)
        end)
      end
    end,
  })
end

return M
