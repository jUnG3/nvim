-- lua/config/gradle_telescope.lua

-- Ensure Telescope is loaded before we use it
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  vim.notify("[Gradle] Telescope not available. Install/enable telescope.nvim.", vim.log.levels.ERROR)
  return
end

local pickers       = require("telescope.pickers")
local finders       = require("telescope.finders")
local conf          = require("telescope.config").values
local actions       = require("telescope.actions")
local action_state  = require("telescope.actions.state")

local M = {}

-- Find the Gradle project root
local function find_gradle_root(start)
  local uv = vim.loop
  local dir = start or vim.fn.expand("%:p:h")
  local function has_marker(d)
    local markers = { "build.gradle", "settings.gradle", "gradlew" }
    for _, m in ipairs(markers) do
      if vim.fn.filereadable(d .. "/" .. m) == 1 then return true end
    end
    return false
  end

  dir = vim.fn.fnamemodify(dir, ":p")
  while dir and dir ~= "/" do
    if has_marker(dir) then return dir end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

-- Prefer ./gradlew if present; otherwise fallback to gradle
local function gradle_cmd(root)
  if vim.fn.executable(root .. "/gradlew") == 1 then
    if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
      return { root .. "/gradlew.bat" }
    end
    return { root .. "/gradlew" }
  end
  return { "gradle" }
end

-- Parse "gradle tasks --all" output into a list of tasks
local function parse_tasks(lines)
  local tasks = {}
  for _, line in ipairs(lines) do
    -- Typical line: "someTask - Description" or ":sub:task - Desc"
    local name, desc = line:match("^%s*([%w%p:]+)%s+%-%s+(.*)$")
    if name then
      table.insert(tasks, { name = name, desc = desc })
    else
      -- Some outputs list bare task names; accept simple tokens
      local bare = line:match("^%s*([%w%p:]+)%s*$")
      if bare and not bare:match("^[%-%s]+$") and not bare:match("Tasks runnable from root project") then
        table.insert(tasks, { name = bare, desc = "" })
      end
    end
  end
  -- Deduplicate
  local seen, out = {}, {}
  for _, t in ipairs(tasks) do
    if not seen[t.name] then
      seen[t.name] = true
      table.insert(out, t)
    end
  end
  table.sort(out, function(a, b) return a.name < b.name end)
  return out
end

-- Collect tasks by running the Gradle command
local function get_tasks(root, cb)
  local cmd = gradle_cmd(root)
  local args = { "tasks", "--all", "--console=plain" }
  local lines = {}

  local job = vim.system(vim.list_extend(cmd, args), {
    cwd = root,
    text = true,
  }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("[Gradle] Failed to list tasks:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      end)
      cb({})
      return
    end
    local output = (res.stdout or ""):gmatch("([^\r\n]+)")
    for l in output do table.insert(lines, l) end
    cb(parse_tasks(lines))
  end)

  if not job then
    vim.notify("[Gradle] Could not start gradle.", vim.log.levels.ERROR)
    cb({})
  end
end

-- Run selected task in a terminal at project root
local function run_task(root, task)
  vim.schedule(function()
    local cmd = gradle_cmd(root)
    local args = { task.name }

    -- Open a terminal split and run
    vim.cmd("botright split | resize 15 | terminal")
    local chan = vim.b.terminal_job_id
    if not chan then
      vim.notify("[Gradle] Terminal not available.", vim.log.levels.ERROR)
      return
    end
    -- Change dir to root and execute
    vim.fn.chansend(chan, "cd " .. vim.fn.fnameescape(root) .. "\n")
    local full = table.concat(vim.list_extend(cmd, args), " ")
    vim.fn.chansend(chan, full .. "\n")
  end)
end

-- Telescope picker for Gradle tasks
function M.pick_gradle_tasks()
  local root = find_gradle_root()
  if not root then
    vim.notify("[Gradle] No Gradle project found (build.gradle/settings.gradle/gradlew).", vim.log.levels.WARN)
    return
  end

  get_tasks(root, function(tasks)
    vim.schedule(function()
      if #tasks == 0 then
        vim.notify("[Gradle] No tasks found.", vim.log.levels.WARN)
        return
      end

      -- Preload Telescope modules at file top:
      -- local pickers = require("telescope.pickers")
      -- local finders = require("telescope.finders")
      -- local conf    = require("telescope.config").values
      -- local actions = require("telescope.actions")
      -- local action_state = require("telescope.actions.state")

      pickers.new({}, {
        prompt_title = "Gradle tasks (" .. root .. ")",
        finder = finders.new_table({
          results = tasks,
          entry_maker = function(t)
            return {
              value = t,
              display = t.name .. (t.desc ~= "" and (" — " .. t.desc) or ""),
              ordinal = t.name .. " " .. (t.desc or ""),
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
          map("i", "<CR>", function(bufnr)
            local entry = action_state.get_selected_entry()
            actions.close(bufnr)
            run_task(root, entry.value)
          end)
          map("n", "<CR>", function(bufnr)
            local entry = action_state.get_selected_entry()
            actions.close(bufnr)
            run_task(root, entry.value)
          end)
          return true
        end,
      }):find()
    end)
  end)
end

return M
