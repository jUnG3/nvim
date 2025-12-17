-- lua/config/meson.lua
local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local uv = vim.loop
local fn = vim.fn

local function is_file(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "file"
end

local function is_dir(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory"
end

-- find project root: prefer LSP workspace, then git root, then upward search for meson.build
local function project_root()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, c in ipairs(clients) do
    local root = c.config and c.config.root_dir
    if root and is_dir(root) then return root end
  end

  local git_root = fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_root and git_root ~= "" and is_dir(git_root) then return git_root end

  local p = vim.fn.expand("%:p")
  if p == "" then p = fn.getcwd() end
  local dir = fn.fnamemodify(p, ":p:h")
  while dir ~= "/" and dir ~= "" do
    if is_file(fn.join({dir, "meson.build"})) then return dir end
    local parent = fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end

  return fn.getcwd()
end

local function find_meson_build_dirs(root)
  local candidates = {}
  if is_file(fn.join({root, "meson.build"})) then
    table.insert(candidates, root)
  end

  local patterns = { "**/build.ninja", "**/meson-info/meson-log.txt", "**/meson-info" }
  local seen = {}
  for _, pat in ipairs(patterns) do
    local matches = fn.globpath(root, pat, false, true) or {}
    for _, m in ipairs(matches) do
      local d = fn.fnamemodify(m, ":p:h")
      if fn.fnamemodify(m, ":t") == "meson-info" then
        d = fn.fnamemodify(m, ":p:h")
      end
      if not seen[d] then
        seen[d] = true
        table.insert(candidates, d)
      end
    end
  end

  local common = { "build", "builddir", "out" }
  for _, name in ipairs(common) do
    local p = fn.join({root, name})
    if is_dir(p) and not seen[p] then
      seen[p] = true
      table.insert(candidates, p)
    end
  end

  if #candidates == 0 then table.insert(candidates, root) end
  return candidates
end

local function run_in_terminal(cmd)
  -- open a terminal and run the cmd string (cmd is a shell command)
  -- use :split to keep editor visible; adjust as you prefer
  vim.cmd("belowright split")
  vim.cmd("terminal " .. cmd)
  -- enter insert mode in the new terminal
  vim.cmd("startinsert")
end

-- main Telescope flow
function M.open_meson_picker()
  local root = project_root()
  local builds = find_meson_build_dirs(root)

  pickers.new({}, {
    prompt_title = "Meson: Select build directory",
    finder = finders.new_table {
      results = builds,
      entry_maker = function(entry)
        return { value = entry, display = entry, ordinal = entry }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map_)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local build_dir = selection.value

        local preset_actions = { "compile", "test", "install", "configure", "clean", "custom..." }
        pickers.new({}, {
          prompt_title = "Meson: Select action (will run with -C " .. build_dir .. ")",
          finder = finders.new_table { results = preset_actions },
          sorter = conf.generic_sorter({}),
          attach_mappings = function(inner_bufnr)
            actions.select_default:replace(function()
              local s = action_state.get_selected_entry()
              actions.close(inner_bufnr)
              local action = s[1]
              if action == "custom..." then
                vim.ui.input({ prompt = "meson command (e.g. compile, test, setup --buildtype debug): " }, function(input)
                  if not input or input == "" then return end
                  local cmd
                  if string.find(input, "%-C") then
                    cmd = "meson " .. input
                  else
                    cmd = "meson " .. input .. " -C " .. vim.fn.shellescape(build_dir)
                  end
                  run_in_terminal(cmd)
                end)
              else
                local cmd = "meson " .. action .. " -C " .. vim.fn.shellescape(build_dir)
                run_in_terminal(cmd)
              end
            end)
            return true
          end,
        }):find()
      end)
      return true
    end,
  }):find()
end

return M
