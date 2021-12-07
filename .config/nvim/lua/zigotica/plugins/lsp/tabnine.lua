-- tabnine setup
local tabnine = require('cmp_tabnine.config')
tabnine:setup({
  max_lines = 100;
  max_num_results = 10;
  sort = true;
  run_on_every_keystroke = true;
  snippet_placeholder = '..';
  ignored_file_types = { -- default is not to ignore
    -- uncomment to ignore in lua:
    -- lua = true
  };
})


