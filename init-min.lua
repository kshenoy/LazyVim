-- Minimal LazyVim-based config for diffs and merges
--
-- Loaded plugins: snacks, gitsigns, lualine, mini.icons, which-key,
--                 mini.pairs, mini.ai, conform (clang-format), tokyonight
--
-- Requires NVIM_APPNAME=nvim-LazyVim to reuse the existing plugin installation.
-- Usage:
--   NVIM_APPNAME=nvim-LazyVim nvim -u ~/.config/nvim-LazyVim/init-min.lua [files]
--   As merge tool:
--     NVIM_APPNAME=nvim-LazyVim nvim -u ~/.config/nvim-LazyVim/init-min.lua -c MergeInit "$BASE" "$REMOTE" "$LOCAL" "$MERGED"
--     git config mergetool.nvim-min.cmd 'NVIM_APPNAME=nvim-LazyVim nvim -u ~/.config/nvim-LazyVim/init-min.lua -c MergeInit "$BASE" "$REMOTE" "$LOCAL" "$MERGED"'
--     git config merge.tool nvim-min

-- Diff-specific options (set early, before plugins load)
vim.opt.diffopt     = 'filler,context:5,algorithm:patience,linematch:60'
vim.opt.showtabline = 2

vim.keymap.set('n', 'ZQ', '<cmd>qall!<cr>', { desc = 'Quit all without saving' })

-- ── Bootstrap lazy.nvim ───────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugin spec ───────────────────────────────────────────────────────────────
require('lazy').setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins', opts = { colorscheme = 'catppuccin-frappe' } },

    -- MergeInit command
    { import = 'plugins.merge' },

    -- conform: clang-format for C/C++ files
    {
      'stevearc/conform.nvim',
      opts = {
        formatters_by_ft = {
          c   = { 'clang_format' },
          cpp = { 'clang_format' },
        },
      },
    },

    -- ── Disabled ──────────────────────────────────────────────────────────────
    { 'folke/flash.nvim',                            enabled = false },
    { 'MagicDuck/grug-far.nvim',                     enabled = false },
    { 'folke/trouble.nvim',                          enabled = false },
    { 'folke/todo-comments.nvim',                    enabled = false },
    { 'akinsho/bufferline.nvim',                     enabled = false },
    { 'folke/noice.nvim',                            enabled = false },
    { 'MunifTanjim/nui.nvim',                        enabled = false },
    { 'folke/ts-comments.nvim',                      enabled = false },
    { 'folke/lazydev.nvim',                          enabled = false },
    { 'nvim-treesitter/nvim-treesitter',             enabled = false },
    { 'nvim-treesitter/nvim-treesitter-textobjects', enabled = false },
    { 'windwp/nvim-ts-autotag',                      enabled = false },
    { 'mfussenegger/nvim-lint',                      enabled = false },
    { 'neovim/nvim-lspconfig',                       enabled = false },
    { 'mason-org/mason.nvim',                        enabled = false },
    { 'mason-org/mason-lspconfig.nvim',              enabled = false },
    { 'folke/persistence.nvim',                      enabled = false },
  },

  defaults  = { lazy = false, version = false },
  lockfile  = vim.fn.stdpath('config') .. '/lazy-min-lock.json',
  install   = { colorscheme = { 'catppuccin', 'habamax' } },
  checker   = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})
