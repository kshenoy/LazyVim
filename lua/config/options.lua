-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- [[ Searching ]]
opt.hlsearch = true -- highlight all matches for the last used search pattern
opt.grepprg = "rg --vimgrep --smart-case" -- LazyVim uses ripgrep but doesn't set smartcase

-- [[ Displaying text ]]
opt.breakindent = true -- wrapped lines preserve visual indent level
opt.showbreak = "↪" -- prefix for wrapped lines
opt.conceallevel = 2 -- hide concealed text (e.g. bold/italic markers in markdown)
opt.concealcursor = "nc" -- also conceal on cursor line in normal and command modes

-- [[ Editing ]]
opt.textwidth = 120 -- line length above which to break a line
opt.colorcolumn = "+1" -- highlight column 121 (textwidth + 1)
opt.softtabstop = -1 -- use shiftwidth value for <Tab> in insert mode
opt.inccommand = "split" -- show live :s/ preview in a split

-- [[ Files ]]
opt.undofile = true -- persist undo history across sessions
opt.swapfile = false -- no swap files; undofile is sufficient

-- [[ listchars ]]
opt.listchars = { extends = "›", precedes = "‹", tab = "» ", trail = "·", nbsp = "␣" }
