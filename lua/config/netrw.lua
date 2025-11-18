-- lua/config/netrw.lua
-- Colemak-DH optimized netrw keymaps

local group = vim.api.nvim_create_augroup("netrw_colemak", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "netrw",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local opts = { buffer = buf, silent = true, nowait = true }

    local function map(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, opts)
    end

    -- Movement: reuse your normal Colemak-DH navigation
    -- n = left, e = down, i = up, o = right
    map("n", "h")  -- press n → move left
    map("e", "j")  -- press e → move down
    map("i", "k")  -- press i → move up
    map("o", "l")  -- press o → move right / open

    -- Keep hjkl also working (if you sometimes switch layouts)
    map("h", "h")
    map("j", "j")
    map("k", "k")
    map("l", "l")

    -- Open in splits / tabs (netrw: v, s, t)
    map("gn", "v")  -- vertical split
    map("ge", "s")  -- horizontal split
    map("go", "t")  -- new tab

    -- Go up directory
    map("gu", "-")  -- up one dir

    -- Refresh listing
    map("gr", "R")

    -- Quit netrw / go back to previous buffer
    map("qq", "<C-^>")
    -- Search (Vim search)
    map("<space>s", "/")

    -- File filter search (netrw filtering)
    map("gs", ":NetrwFilter<CR>")
  end,
})

