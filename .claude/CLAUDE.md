# Claude Instructions for nvim-LazyVim

## Remembered Behaviors

- Store new remembered behaviors here (not in local memory files) so they sync across devices via git.
- Read `README.md` at the start of any session — it documents current customizations, the keymap namespace convention, and deferred plugins.
- After any change to keymaps, options, plugins, or config structure: update `README.md` so it stays accurate as the single source of truth for all differences from the LazyVim starter.

## README TODO format

When documenting in-progress work in `README.md`, use this format (placed after the main section content):

```
#### TODO <short description>

<problem statement paragraph>

**Status**
<current status / what's been tried / what's pending>
```

Remove the TODO once resolved

## LazyVim import order

The global spec order in `lua/config/lazy.lua` must be:
1. `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` — LazyVim core
2. `{ import = "lazyvim.plugins.extras.*" }` — any extras, one entry each
3. `{ import = "plugins" }` — user's own plugins

**Extras go in `lazy.lua`, not in `lua/plugins/` files.** Putting `{ import = "lazyvim.plugins.extras.*" }` inside a `lua/plugins/` file causes import order errors at startup because those files are processed as part of step 3, after the core is already resolved.

## Conditional spec entries in lazy.lua

Never use `condition and value or nil` inline inside the lazy.nvim spec table. `ipairs()` stops at the first `nil`, silently skipping all subsequent entries (including `{ import = "plugins" }`). Use `table.insert()` conditionally instead — see `lua/config/lazy.lua` for the pattern.

## Local/machine-specific config

See `README.md` for the full convention. Key constraints:
- LazyVim extras must still go in `lazy.lua` — extras inside `lua/local/` cause import order errors
- Files in `lua/local/` must each `return {}` or a valid spec table — returning `nil` causes a lazy startup error
