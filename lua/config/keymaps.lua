-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Unbind C-h/j/k/l window switching (LazyVim defaults)
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")

-- Quit all files without saving; counterpart to 'ZZ'
vim.keymap.set("n", "ZQ", "<cmd>qall!<cr>", { desc = "Quit all without saving" })

-- LazyVim remaps j→gj and k→gk so motion follows visual lines by default.
-- Add the inverse so real-line motion is still reachable via gj/gk.
vim.keymap.set({ "n", "x" }, "gj", "j", { desc = "Down (real line)" })
vim.keymap.set({ "n", "x" }, "gk", "k", { desc = "Up (real line)" })

-- Swap U ↔ <C-R>: U is easier to reach than <C-R> for redo
-- Original U (undo whole line) is rarely useful; redo is used constantly.
vim.keymap.set("n", "U", "<C-R>", { silent = true, desc = "Redo" })
vim.keymap.set("n", "<C-R>", "U", { silent = true, desc = "Undo line" })

-- Fix cw/cW: cw in vim includes trailing whitespace, unlike dw/yw (:h cw).
-- This fixes the inconsistency so cw changes to end-of-word only. Use ce for old behaviour.
vim.keymap.set("n", "cw", "dwi", { desc = "Change word" })
vim.keymap.set("n", "cW", "dWi", { desc = "Change WORD" })

-- Replace word under cursor
-- Jumps to the first match, then enters cgn so the change can be repeated with . on subsequent matches
vim.keymap.set("n", "c*", "*<C-O>cgn", { desc = "Replace word under cursor" })
vim.keymap.set("n", "cg*", "g*<C-O>cgn", { desc = "Replace word under cursor (no boundary)" })

-- Copy full file path to clipboard
vim.keymap.set("n", "<leader>fy", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.fn.setreg("*", vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

-- Toggle cursorline/cursorcolumn
-- Mnemonic: _ looks like a horizontal line (cursorline), | like a vertical one (cursorcolumn).
Snacks.toggle.option("cursorline", { name = "Cursorline" }):map("<leader>u_")
Snacks.toggle.option("cursorcolumn", { name = "Cursorcolumn" }):map("<leader>u|")

-- Fill remainder of current line up to 'textwidth' with a prompted character.
-- Usage: <leader>mf, then press the fill character (e.g. '-', '=').
vim.keymap.set("n", "<leader>mf", function()
  local fill_char = vim.fn.nr2char(vim.fn.getchar())
  local fill_amt = vim.opt.textwidth:get() - vim.api.nvim_get_current_line():len()
  local fill_str = string.rep(fill_char, fill_amt)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { fill_str })
end, { desc = "Fill-width with character" })
