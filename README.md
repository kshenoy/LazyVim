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

---

## Customizations over the starter

### Keymaps (`lua/config/keymaps.lua`)
| Key | Mode | Description |
|-----|------|-------------|
| `ZQ` | n | Quit all without saving (`qall!`) |

### Colorscheme (`lua/plugins/colorscheme.lua`)
- Uses **catppuccin-frappe** instead of the default tokyonight

### UI (`lua/plugins/ui.lua`)
- Disables **bufferline** (`akinsho/bufferline.nvim`)

### Snacks (`lua/plugins/snacks.lua`)
| Key | Description |
|-----|-------------|
| `<leader><leader>` | Buffers picker |
| `<leader>bb` | Buffers picker (overrides default "Switch to Other Buffer") |
| `<leader>f.` | Find Files (cwd) (`.` refers to cwd in Unix) |
| `<leader>f,` | Find Config File (`,` used because macOS reserves it for Settings) |
| `<leader>s.` | Grep (cwd) (`.` refers to cwd in Unix) |
