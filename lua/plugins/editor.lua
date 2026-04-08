return {
  -- dial.nvim: extends <C-a>/<C-x> with rich augends (booleans, dates, hex, etc.)
  -- Extra is imported in lazy.lua; here we extend the default group with a custom augend.
  {
    "monaqa/dial.nvim",
    opts = function(_, opts)
      local augend = require("dial.augend")
      -- Cycle between C-style member access operators
      table.insert(opts.groups.default, augend.constant.new({
        elements = { ".", "->", "::" },
        word = false,
        cyclic = true,
      }))
    end,
  },

  -- mini.surround: imported in lazy.lua. Default gs* mappings used (gsa/gsd/gsr/gsf/gsF/gsh/gsn).
}
