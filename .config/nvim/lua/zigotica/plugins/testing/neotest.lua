-- get neotest namespace (api call creates or returns namespace)
-- simplified from https://github.com/nvim-neotest/neotest-go

local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message
      lines = {}
      string.gsub(message, "[^\n]+", function(str)
        table.insert(lines, str)
      end)
      return lines[1] .. " " .. lines[2]
    end,
  },
}, neotest_ns)

local function has_workspaces()
  local root_path = vim.fn.getcwd()
  local package_json = root_path .. "/package.json"

  if vim.fn.filereadable(package_json) == 0 then
    return false
  end

  local content = vim.fn.readfile(package_json)
  local json = vim.fn.json_decode(content)

  return json.workspaces ~= nil
end

local function get_config_path(dir_path)
  if vim.fn.filereadable(dir_path .. "/jest.config.mjs") == 1 then
    return dir_path .. "/jest.config.mjs"
  end
  return dir_path .. "/jest.config.js"
end

require("neotest").setup({
  adapters = {
    require("neotest-jest")({
      jestCommand = function()
        local file = vim.fn.expand("%:p")
        file = file:gsub("\\", "/")

        -- Get Git root (fallback to cwd if not in a repo)
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if not git_root or git_root == "" then
          git_root = vim.loop.cwd()
        end

        -- Detect workspace (e.g., app or app-nextjs)
        local workspace = file:match("/(app[^/]*)/")
        local workspace_path = workspace and (git_root .. "/" .. workspace) or git_root

        -- Path to local Jest binary
        local jest_bin = workspace_path .. "/node_modules/.bin/jest"
        if vim.fn.filereadable(jest_bin) == 0 then
          jest_bin = git_root .. "/node_modules/.bin/jest"
        end
        if vim.fn.filereadable(jest_bin) == 0 then
          jest_bin = "jest"
        end

        -- Run Jest directly from the workspace
        return string.format("%s --watchAll=false", jest_bin)
      end,

      cwd = function()
        local file = vim.fn.expand("%:p")
        file = file:gsub("\\", "/")

        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if not git_root or git_root == "" then
          git_root = vim.loop.cwd()
        end

        local workspace = file:match("/(app[^/]*)/")
        return workspace and (git_root .. "/" .. workspace) or git_root
      end,

      jestConfigFile = function()
        local file = vim.fn.expand("%:p")
        file = file:gsub("\\", "/")

        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if not git_root or git_root == "" then
          git_root = vim.loop.cwd()
        end

        local workspace = file:match("/(app[^/]*)/")
        local candidates = {}

        if workspace then
          table.insert(candidates, git_root .. "/" .. workspace .. "/jest.config.ts")
          table.insert(candidates, git_root .. "/" .. workspace .. "/jest.config.js")
        end
        table.insert(candidates, git_root .. "/jest.config.ts")
        table.insert(candidates, git_root .. "/jest.config.js")

        for _, path in ipairs(candidates) do
          if vim.fn.filereadable(path) == 1 then
            return path
          end
        end
        return nil
      end,
    }),
  },
})


-- Keymaps
vim.keymap.set('n', '<leader>tr', '<cmd>lua require("neotest").run.run();require("neotest").summary.open()<CR>', {desc='[T]est [R]un'})
vim.keymap.set('n', '<leader>ts', '<cmd>lua require("neotest").run.stop();require("neotest").summary.close()<CR>', {desc='[T]est [S]top'})
vim.keymap.set('n', '<leader>tt', '<cmd>lua require("neotest").summary.toggle()<CR>', {desc='[T]est [T]oggle summary'})

