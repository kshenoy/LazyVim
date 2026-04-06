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
        "<leader>f.",
        function()
          LazyVim.pick("files", { root = false, cwd = vim.fn.expand("%:p:h") })()
        end,
        desc = "Find Files (file dir)",
      }, -- '.' because it refers to cwd in Unix
      {
        "<leader>f,",
        function()
          LazyVim.pick.config_files()()
        end,
        desc = "Find Config File",
      }, -- ',' because MacOS uses it for settings
      -- search
      {
        "<leader>s.",
        function()
          LazyVim.pick("live_grep", { root = false, cwd = vim.fn.expand("%:p:h") })()
        end,
        desc = "Grep (file dir)",
      }, -- '.' because it refers to cwd in Unix
    },
  },
}
