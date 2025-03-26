local avante_config = {
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "vertex" | "cohere" | "copilot" | "bedrock" | string
  ---------------- PROVIDERS
  -- Switch by using :AvanteSwitchProvider name, or <leader>ap
  provider = "gemini",
  -- Show prices next to the model name in the <leader>ap picker
  prices = {
    ollama_R1 = "FREE",
    ollama_Llama_32 = "FREE",
    requesty_Deepseek_v3 = "Input (1M)$0.850 Output (1M)$0.900",
    requesty_GPT4mini = "Input (1M)$0.150 Output (1M)$0.600",
    requesty_Llama_33 = "Input (1M)$0.120 Output (1M)$0.300",
    claude = "Input (1M)$3.000 Output (1M)$15.000",
  },
  ---------------- PROVIDER SETUPS
  vendors = {
    ollama_R1 = {
      __inherited_from = "openai",
      endpoint = "http://127.0.0.1:11434/v1",
      api_key_name = "",
      model = "deepseek-r1",
      max_tokens = 16384,
    },
    ollama_Llama_32 = {
      __inherited_from = "openai",
      endpoint = "http://127.0.0.1:11434/v1",
      api_key_name = "",
      model = "llama3.2",
      max_tokens = 16384,
    },
    requesty_Deepseek_v3 = {
      __inherited_from = "openai",
      endpoint = "https://router.requesty.ai/v1",
      api_key_name = "REQUESTY_API_KEY",
      model = "deepinfra/deepseek-ai/DeepSeek-V3",
      temperature = 0,
      max_tokens = 16384,
    },
    requesty_GPT4mini = {
      __inherited_from = "openai",
      endpoint = "https://router.requesty.ai/v1",
      api_key_name = "REQUESTY_API_KEY",
      model = "openai/gpt-4o-mini",
      temperature = 0,
      max_tokens = 16384,
    },
    requesty_Llama_33 = {
      __inherited_from = "openai",
      endpoint = "https://router.requesty.ai/v1",
      api_key_name = "REQUESTY_API_KEY",
      model = "deepinfra/meta-llama/Llama-3.3-70B-Instruct-Turbo",
      temperature = 0,
      max_tokens = 16384,
    },
    google_Flash = {
      __inherited_from = "gemini",
      model = "gemini-2.0-flash",
    },
  },
  gemini = {
    endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
    api_key_name = "GEMINI_API_KEY",
    model = "gemini-2.5-pro-exp-03-25",
    temperature = 0,
    max_tokens = 32768,
  },
  claude = { -- Claude does not use the vendors object
    endpoint = "https://api.anthropic.com",
    model = "claude-3-7-sonnet-20250219",
    temperature = 0,
    max_tokens = 16384,
  },
  ---------------- COMMON SETTINGS
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
  },
  mappings = {
    --- @class AvanteConflictMappings
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
    },
  },
  hints = { enabled = true },
  windows = {
    ---@type "right" | "left" | "top" | "bottom"
    position = "right", -- the position of the sidebar
    wrap = true,      -- similar to vim.o.wrap
    width = 50,       -- default % based on available width
    sidebar_header = {
      enabled = true, -- true, false to enable/disable the header
      align = "center", -- left, center, right for title
      rounded = true,
    },
    input = {
      prefix = "> ",
      height = 15, -- Height of the input window in vertical layout
    },
    edit = {
      border = "rounded",
      start_insert = true, -- Start insert mode when opening the edit window
    },
    ask = {
      floating = false, -- Open the 'AvanteAsk' prompt in a floating window
      start_insert = true, -- Start insert mode when opening the ask window
      border = "rounded",
      ---@type "ours" | "theirs"
      focus_on_apply = "theirs", -- which diff to focus after applying
    },
  },
  highlights = {
    ---@type AvanteConflictHighlights
    diff = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
  },
  --- @class AvanteConflictUserConfig
  diff = {
    autojump = true,
    ---@type string | fun(): any
    list_opener = "copen",
    --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
    --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
    --- Disable by setting to -1.
    override_timeoutlen = 500,
  },
}
require("avante").setup(avante_config)
require("avante_lib").load()

-- Add functions to the module
local M = require("avante")

-- Function to get the configuration
function M.get_config()
  return avante_config
end

-- Function to get all provider keys (official + custom vendors)
function M.get_providers()
  local providers = {}

  -- Add vendors
  for key, _ in pairs(avante_config.vendors) do
    table.insert(providers, key)
  end

  -- List of additional providers to check
  local additional_providers = { "claude", "openai", "azure", "gemini", "vertex", "cohere", "copilot", "bedrock" }

  -- Check for additional providers
  for _, provider in ipairs(additional_providers) do
    if avante_config[provider] then
      table.insert(providers, provider)
    end
  end

  -- Function to extract and convert price for sorting
  local function get_price_value(provider)
    -- if price entry doesn't exist, take it as 0
    local price_str = avante_config.prices[provider] or "N/A"
    if price_str == "N/A" or price_str == "FREE" then
      return 0
    else
      -- Attempt to extract numerical values from the price string
      local input_cost = string.match(price_str, "Input %(1M%)$([%d%.]+)") or "0"
      local output_cost = string.match(price_str, "Output %(1M%)$([%d%.]+)") or "0"
      return tonumber(input_cost) + tonumber(output_cost)
    end
  end

  -- Sort providers by price
  table.sort(providers, function(a, b)
    return get_price_value(a) < get_price_value(b)
  end)

  return providers
end

-- For backward compatibility, create global aliases
_G.get_avante_config = M.get_config
_G.get_avante_vendors = M.get_providers

-- Create a telescope picker for Avante providers
function M.telescope_providers()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local providers = M.get_providers()
  -- Always get the fresh current provider value from the config
  local current_provider = M.get_config().provider

  local opts = {
    prompt_title = "Avante Providers",
    results_title = "Available Providers",
    finder = require("telescope.finders").new_table({
      results = providers,
      entry_maker = function(entry)
        -- Get the current provider value each time this function is called
        local current = M.get_config().provider
        local prices = avante_config.prices
        local price = prices[entry] or "N/A"

        -- Function to transform the price string
        local function transform_price(price_string)
          local input_price, output_price =
              string.match(price_string, "Input %(1M%)%$([%d%.]+) Output %(1M%)%$([%d%.]+)")
          if input_price and output_price then
            return string.format("$%s/M in $%s/M out", input_price, output_price)
          else
            return price_string
          end
        end
        local formatted_price = price ~= "" and transform_price(price) or ""

        -- format entry
        local display_name = entry
        local model_name = ""

        -- Check if the entry is a vendor (contains an underscore)
        local provider, model = string.match(entry, "^([^_]*)_?(.*)$")
        if provider and model then
          -- If it's a vendor, separate the provider and model names
          display_name = string.upper(provider)
          model_name = model
        else
          -- If it's not a vendor, uppercase the display name
          display_name = string.gsub(entry, "^([^ _]*)", string.upper)
        end

        -- Manually set display names for specific providers
        if entry == "gemini" then
          display_name = "GOOGLE"
        elseif entry == "claude" then
          display_name = "ANTHROPIC"
        end

        display_name = string.gsub(display_name, "_", " ")
        model_name = string.gsub(model_name, "_", " ")

        -- Get model name from config if available, before any string manipulation
        if avante_config[entry] and avante_config[entry].model then
          model_name = avante_config[entry].model
        end

        -- Calculate padding for provider name
        local max_provider_length = 12 -- Adjust this value based on the longest provider name
        local provider_padding_length = max_provider_length - string.len(display_name)
        local provider_padding = string.rep(" ", math.max(0, provider_padding_length))

        -- Calculate padding for model name
        local max_model_length = 30 -- Adjust this value based on the longest model name
        local model_padding_length = max_model_length - string.len(model_name)
        local model_padding = string.rep(" ", math.max(0, model_padding_length))

        return {
          value = entry,
          display = display_name
              .. provider_padding
              .. "\t"
              .. model_name
              .. model_padding
              .. "\t"
              .. formatted_price
              .. (entry == current and " (current)" or ""),
          ordinal = entry,
        }
      end,
    }),
    sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        local selected_provider = selection.value

        -- Update the provider in the config
        avante_config.provider = selected_provider

        -- Execute the command to switch providers
        vim.cmd("AvanteSwitchProvider " .. selected_provider)
        vim.notify("Switched to provider: " .. selected_provider, vim.log.levels.INFO)

        -- Don't reopen the picker automatically
      end)
      return true
    end,
  }

  require("telescope.pickers").new({}, opts):find()
end

-- Create a user command for the telescope picker
vim.api.nvim_create_user_command("AvanteProviders", function()
  M.telescope_providers()
end, {})

vim.keymap.set("n", "<leader>ap", function()
  require("avante").telescope_providers()
end, { desc = "Avante Providers" })
