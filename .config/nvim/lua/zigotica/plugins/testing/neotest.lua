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
        local workspace = file:match("/app[^/]*/") -- matches /app/ or /app-something/
        local has_ws = has_workspaces()
        local command
        -- local is_test = file:match("%.test%.") or file:match("%.spec%.")
        -- local config

        if workspace then
          workspace = workspace:gsub("/", "") -- remove slashes
          -- local workspace_path = vim.fn.getcwd() .. "/" .. workspace
          -- config = get_config_path(workspace_path)

          if has_ws then
            command = string.format("npm run test --workspace=%s -- --watch", workspace)
          else
            command = "npm run test -- --watch"
          end
        else
          -- config = get_config_path(vim.fn.getcwd())
          command = "npm run test -- --watch"
        end

        -- print(
        -- 	string.format(
        -- 		"DEBUG Neotest-jest: full_path='%s', is_test_file=%s, workspace='%s', has_workspaces=%s, command='%s', config='%s'",
        -- 		file,
        -- 		is_test and "true" or "false",
        -- 		workspace or "none",
        -- 		has_ws,
        -- 		command,
        -- 		config
        -- 	)
        -- )
        return command
      end,
      jestConfigFile = function()
        local file = vim.fn.expand("%:p")
        local workspace = file:match("/app[^/]*/")

        if workspace then
          workspace = workspace:gsub("/", "") -- remove slashes
          local workspace_path = vim.fn.getcwd() .. "/" .. workspace
          return get_config_path(workspace_path)
        end

        return get_config_path(vim.fn.getcwd())
      end,
    }),
  },
})
