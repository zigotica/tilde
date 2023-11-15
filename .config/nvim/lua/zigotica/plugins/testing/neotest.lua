-- get neotest namespace (api call creates or returns namespace)
-- simplified from https://github.com/nvim-neotest/neotest-go
local neotest_ns = vim.api.nvim_create_namespace('neotest')
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message
      lines = {}
      string.gsub (message, '[^\n]+',
        function (str)
          table.insert (lines, str)
        end
      )
      return lines[1]..' '..lines[2]
    end,
  },
}, neotest_ns)

require('neotest').setup({
  adapters = {
    require('neotest-jest')({
      jestCommand = function()
        local file = vim.fn.expand('%:p')
        if string.find(file, '/app/') then
          return 'npm run test --workspace=app -- --watch'
        end

        return 'npm run test -- --watch'
      end,
      jestConfigFile = function()
        local file = vim.fn.expand('%:p')
        if string.find(file, '/app/') then
          return vim.fn.getcwd() .. '/app/jest.config.mjs'
        end

        return vim.fn.getcwd() .. 'jest.config.js'
      end,
    }),
  },
})
