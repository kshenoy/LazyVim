return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader><leader>",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      -- buffers
      {
        "<leader>bb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      -- find
      {
        "<leader>f,",
        function()
          LazyVim.pick.config_files()()
        end,
        desc = "Find Config File",
      }, -- ',' because MacOS uses it for settings
      {
        "<leader>fF",
        function()
          LazyVim.pick("files", { root = false, cwd = vim.fn.expand("%:p:h") })()
        end,
        desc = "Find Files (file dir)",
      },
      -- grep
      {
        "<leader>sG",
        function()
          LazyVim.pick("live_grep", { root = false, cwd = vim.fn.expand("%:p:h") })()
        end,
        desc = "Grep (file dir)",
      },
      {
        "<leader>sW",
        function()
          LazyVim.pick("grep_word", { root = false, cwd = vim.fn.expand("%:p:h") })()
        end,
        desc = "Visual selection or word (file dir)",
        mode = { "n", "x" },
      },
      -- explorer
      {
        "<leader>fE",
        function()
          Snacks.explorer({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Explorer Snacks (file dir)",
      },
      { "<leader>E", "<leader>fE", desc = "Explorer Snacks (file dir)", remap = true },
    },
  },
}
