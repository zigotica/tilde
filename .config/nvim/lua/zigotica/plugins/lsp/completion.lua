vim.opt.completeopt = { 'menu', 'menuone', 'preview', 'noselect', 'noinsert' }

-- Snippets
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load({
  paths = {
    "~/.config/nvim/snippets/",              -- personal snippets
    vim.fn.expand("$DIR_WORK/HNZ/snippets/") -- work snippets
  }
})
luasnip.config.set_config({
  -- update dynamic snippets as you type
  updateevents = 'TextChanged,TextChangedI',
  -- to move in & out of snippets
  history = true,
  -- Disable autotriggered snippets, we'll only use them from completion
  enable_autosnippets = false,
})

-- Tab completion helper
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Configure the icons for sources, used in formatting
local shared_icons = require "zigotica.common.icons"
local source_type_icons = shared_icons.lsp_completion

local border_style = require "zigotica.common.borders"
local hl_style = require "zigotica.common.highlight"

-- Setup nvim-cmp.
local cmp = require 'cmp'

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    -- default mappings
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- remove default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),

    -- Accept currently selected item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    -- ['<CR>'] = cmp.mapping(function(fallback)
    --     if cmp.visible() then
    --         if luasnip.expandable() then
    --             luasnip.expand()
    --         else
    --             cmp.confirm({ select = false })
    --         end
    --     else
    --         fallback()
    --     end
    -- end),

    -- navigate to next/prev suggestions
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        else
          cmp.select_next_item()
        end
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          cmp.select_prev_item()
        end
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = 'luasnip' },
    { name = "codeium" },
    { name = 'cmp_tabnine' },
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = function(entry, vim_item)
      -- This concatenates the icons with the name of the item kind
      vim_item.kind = string.format('%s %s', source_type_icons[vim_item.kind], vim_item.kind)
      -- Sources
      vim_item.menu = ({
        luasnip = "[Snip]",
        codeium = "[Cod]",
        cmp_tabnine = "[Tab9]",
        nvim_lsp = "[LSP]",
        buffer = "[Buffer]",
        path = "[Path]",
        nvim_lua = "[Lua]",
      })[entry.source.name]
      -- tweak Codeium icon
      if entry.source.name == 'codeium' then
        vim_item.kind = source_type_icons.Codeium
        local detail = (entry.completion_item.data or {}).detail
        if detail and detail:find('.*%%.*') then
          vim_item.kind = vim_item.kind .. ' ' .. detail
        end

        if (entry.completion_item.data or {}).multiline then
          vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
        end
      end
      -- tweak Tabnine icon
      if entry.source.name == 'cmp_tabnine' then
        vim_item.kind = source_type_icons.Tab9
        local detail = (entry.completion_item.data or {}).detail
        if detail and detail:find('.*%%.*') then
          vim_item.kind = vim_item.kind .. ' ' .. detail
        end

        if (entry.completion_item.data or {}).multiline then
          vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
        end
      end
      return vim_item
    end
  },
  window = {
    completion = {
      border = border_style,
      winhighlight = hl_style,
      side_padding = 0,
    },
    documentation = {
      border = border_style,
      winhighlight = hl_style,
    },
  },
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- remove some sources when buffer is not a language filetype
require("cmp").setup.filetype("", {
  sources = {
    {
      name = 'buffer',
      path = 'path'
    }
  }
})
