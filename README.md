# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Directory Conventions

### `lua/config/`
Neovim-level configuration, auto-loaded by LazyVim at the appropriate time. Do **not** `require` these manually.
- `options.lua` — `vim.opt.*` settings
- `keymaps.lua` — `vim.keymap.set(...)` calls
- `autocmds.lua` — `vim.api.nvim_create_autocmd(...)` calls
- `lazy.lua` — lazy.nvim bootstrap (don't touch)

### `lua/plugins/`
lazy.nvim plugin specs. Multiple files are merged together. Use to add new plugins or override/extend existing LazyVim plugins.

**Note:** `opts`, `keys`, `cmd`, `event`, `ft` **extend** existing LazyVim defaults; other spec properties (e.g. `config`) **replace** them.

**Rule of thumb:** If it's a `vim.*` call that doesn't depend on a plugin, it goes in `lua/config/`. If it involves configuring a plugin, it goes in `lua/plugins/`.

### Keymap namespaces

`<leader>m` is the personal keymap namespace ("m" for *mine*). Use `<leader>m<key>` for custom keymaps that don't belong to an existing LazyVim namespace. The group is registered in `lua/plugins/which-key.lua` with label `personal` and icon `󰀄`.

---

## Customizations over the starter

### Keymaps (`lua/config/keymaps.lua`)
| Key | Mode | Description |
|-----|------|-------------|
| `ZQ` | n | Quit all without saving (`qall!`) |
| `gj` / `gk` | n, x | Down/Up by real line (inverse of LazyVim's `j`/`k` → `gj`/`gk` remap) |
| `U` | n | Redo (swapped with `<C-R>` for ergonomics) |
| `<C-R>` | n | Undo line (original `U` behaviour) |
| `cw` / `cW` | n | Change word/WORD to end-of-word (fixes vim's trailing-space inconsistency, see `:h cw`) |
| `c*` / `cg*` | n | Replace word under cursor; use `.` to repeat on next match |
| `<leader>fy` | n | Copy full file path to clipboard |
| `<leader>mf` | n | Fill remainder of line to `textwidth` with a prompted character |
| `<leader>u_` | n | Toggle `cursorline` |
| `<leader>u\|` | n | Toggle `cursorcolumn` |

### Colorscheme (`lua/plugins/colorscheme.lua`)
- Uses **catppuccin-frappe** instead of the default tokyonight

### UI (`lua/plugins/ui.lua`)
- Disables **bufferline** (`akinsho/bufferline.nvim`)

### Plugins (`lua/plugins/editor.lua`)
- **dial.nvim** (LazyVim extra) — extends `<C-a>`/`<C-x>` with booleans, dates, hex colours, weekdays, semver, and custom `.`/`->`/`::` cycling. Replaces kickstart's `boole.nvim`.
- **mini.surround** (LazyVim extra) — surround operations via `gs*` keys: `gsa` add, `gsd` delete, `gsr` replace, `gsf`/`gsF` find, `gsh` highlight, `gsn` n_lines.

### Snacks (`lua/plugins/snacks.lua`)
| Key | Description |
|-----|-------------|
| `<leader><leader>` | Buffers picker |
| `<leader>bb` | Buffers picker (overrides default "Switch to Other Buffer") |
| `<leader>f.` | Find Files (cwd) (`.` refers to cwd in Unix) |
| `<leader>f,` | Find Config File (`,` used because macOS reserves it for Settings) |
| `<leader>s.` | Grep (cwd) (`.` refers to cwd in Unix) |

---

## Deferred from kickstart (not yet ported)

| Plugin | Notes |
|--------|-------|
| `tpope/vim-sleuth` | Auto-detects indent from file content. Neovim 0.9+ has built-in editorconfig; revisit if needed on projects without `.editorconfig`. |
| `echasnovski/mini.align` | Text alignment operations. No LazyVim equivalent. |
| `echasnovski/mini.bracketed` | Bracket-based navigation. No LazyVim equivalent. |
| `echasnovski/mini.operators` | Extra operators. No LazyVim equivalent. |
