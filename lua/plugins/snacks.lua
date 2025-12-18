return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><leader>", function() Snacks.picker.buffers() end, desc = "Buffers", },
      -- buffers
      { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffers", },
      { "<leader>bB", function() Snacks.picker.buffers() end, desc = "Buffers (All)", },
      -- find
      { "<leader>fb", false },
      { "<leader>fB", false },
      { "<leader>f.", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>f,", LazyVim.pick.config_files(), desc = "Find Config File" },  -- ',' because MacOS uses it for settings
      { "<leader>fc", false },
      -- search
      { "<leader>s.", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    },
  },
}
