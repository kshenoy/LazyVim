return {
  -- dial.nvim: extends <C-a>/<C-x> with rich augends (booleans, dates, hex, etc.)
  -- Replaces kickstart's boole.nvim. Extra is imported in lazy.lua; here we extend
  -- the default group with the one custom augend from kickstart.
  {
    "monaqa/dial.nvim",
    opts = function(_, opts)
      local augend = require("dial.augend")
      -- Cycle between C-style member access operators (from kickstart boole config)
      table.insert(opts.groups.default, augend.constant.new({
        elements = { ".", "->", "::" },
        word = false, -- match kickstart: no word boundaries required
        cyclic = true,
      }))
    end,
  },

  -- mini.surround: imported in lazy.lua. Default gs* mappings match kickstart's
  -- gs* prefix exactly. Only difference: gsr (replace) vs kickstart's gsc (change).
}
