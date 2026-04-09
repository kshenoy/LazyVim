# Claude Instructions for nvim-LazyVim

## Getting context

Read `README.md` at the start of any session — it documents current customizations, the keymap namespace convention, and deferred plugins.

## LazyVim import order

The global spec order in `lua/config/lazy.lua` must be:
1. `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` — LazyVim core
2. `{ import = "lazyvim.plugins.extras.*" }` — any extras, one entry each
3. `{ import = "plugins" }` — user's own plugins

**Extras go in `lazy.lua`, not in `lua/plugins/` files.** Putting `{ import = "lazyvim.plugins.extras.*" }` inside a `lua/plugins/` file causes import order errors at startup because those files are processed as part of step 3, after the core is already resolved.

## Conditional spec entries in lazy.lua

Never use `condition and value or nil` inline inside the lazy.nvim spec table. `ipairs()` stops at the first `nil`, silently skipping all subsequent entries (including `{ import = "plugins" }`). Use `table.insert()` conditionally instead — see `lua/config/lazy.lua` for the pattern.

## Work-specific config

- Lives in `lua/work/` (symlinked to `~/.config/dotfiles-priv/nvim/work/`), gitignored
- Loaded only when `$STEM` is set, via conditional `table.insert` in `lazy.lua`
- LazyVim extras (e.g. clangd) must still go in `lazy.lua` — extras inside `lua/work/` cause import order errors

## Key files

- `lua/plugins/merge.lua` — 4-way MergeInit command; always loaded; supports git/git-diff3/perforce auto-detected at invocation time
- `init-min.lua` — minimal LazyVim-based config for diffs/merges; invoke with `NVIM_APPNAME=nvim-LazyVim nvim -u ~/.config/nvim-LazyVim/init-min.lua`; reuses the existing plugin installation
- `lua/work/` files must each `return {}` or a valid spec table — returning `nil` causes a lazy startup error

## Remembered Behaviors

Store new remembered behaviors here (not in local memory files) so they sync across devices via git.
