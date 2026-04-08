# Claude Instructions for nvim-LazyVim

## Getting context

Read `README.md` at the start of any session — it documents current customizations, the keymap namespace convention, and deferred plugins.

## LazyVim import order

The global spec order in `lua/config/lazy.lua` must be:
1. `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` — LazyVim core
2. `{ import = "lazyvim.plugins.extras.*" }` — any extras, one entry each
3. `{ import = "plugins" }` — user's own plugins

**Extras go in `lazy.lua`, not in `lua/plugins/` files.** Putting `{ import = "lazyvim.plugins.extras.*" }` inside a `lua/plugins/` file causes import order errors at startup because those files are processed as part of step 3, after the core is already resolved.

## Remembered Behaviors

Store new remembered behaviors here (not in local memory files) so they sync across devices via git.
