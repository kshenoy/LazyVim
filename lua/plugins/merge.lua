-- 4-way merge helper for Git and Perforce merges
--
-- Usage:
--   Git:       git config mergetool.nvim.cmd 'nvim -c MergeInit "$BASE" "$REMOTE" "$LOCAL" "$MERGED"'
--              git config merge.tool nvim
--
--   Perforce:  nvim -c MergeInit "$ORIGINAL" "$THEIRS" "$YOURS" "$MERGE"
--
-- Layout:
--   Tab 1 (Main):  BASE   | REMOTE | LOCAL (top), MERGED (bottom) — all diffed
--   Tab 2:         REMOTE | MERGED | LOCAL (3-way)
--   Tab 3:         LOCAL  | MERGED
--   Tab 4:         REMOTE | MERGED
--   Tab 5:         BASE   | REMOTE
--   Tab 6:         BASE   | LOCAL
--   Tab 7:         REMOTE | LOCAL
--
-- Conflict markers detected automatically:
--   Git:       <<<<<<< / ======= / >>>>>>>
--   Git diff3: <<<<<<< / ||||||| / ======= / >>>>>>>
--   Perforce:  >>>> ORIGINAL / ==== THEIRS / ==== YOURS / <<<<
--
-- Keymaps (buffer-local on the merge file):
--   [C / ]C         previous / next conflict marker
--   iC / aC         text object: whole conflict block (inner/around)
--   Git (default):       Git (diff3):         Perforce:
--   ilC/alC (Local)      ilC/alC (Local)      ioC/aoC (Original)
--   irC/arC (Remote)     ibC/abC (Base)       itC/atC (Theirs)
--                        irC/arC (Remote)     iyC/ayC (Yours)
--   dgl (accept Local)   dgl (accept Local)   dgo (accept Orig)
--   dgr (accept Remote)  dgb (accept Base)    dgt (accept Theirs)
--                        dgr (accept Remote)  dgy (accept Yours)

-- Module-level context: populated by setup_ctx() at MergeInit time
local ctx = {}

-- Detect VCS type from environment and merge file content
local function detect_vcs(merge_file)
  -- Perforce: $STEM is set in all Perforce work areas
  if vim.env.STEM and vim.env.STEM ~= '' then return 'perforce' end
  -- Git diff3: scan for the base marker (||||||| ) in the merge file
  for _, line in ipairs(vim.fn.readfile(merge_file, '', 200)) do
    if line:match('^|||||||') then return 'git_diff3' end
  end
  return 'git'
end

-- Populate ctx based on detected VCS type
local function setup_ctx(vcs)
  if vcs == 'perforce' then
    ctx = {
      vcs         = 'perforce',
      base_str    = 'Original', remote_str = 'Theirs',
      local_str   = 'Yours',    merge_str  = 'Merged',
      three_block = true,
      P = { b1 = '^>>>> ORIGINAL', b2 = '^==== THEIRS', b3 = '^==== YOURS', end_ = '^<<<<' },
      keys  = { [1] = 'o',        [2] = 't',      [3] = 'y'     },
      names = { [1] = 'Original', [2] = 'Theirs', [3] = 'Yours' },
    }
  elseif vcs == 'git_diff3' then
    ctx = {
      vcs         = 'git_diff3',
      base_str    = 'Base',   remote_str = 'Remote',
      local_str   = 'Local',  merge_str  = 'Merged',
      three_block = true,
      P = { b1 = '^<<<<<<< ', b2 = '^||||||| ', b3 = '^=======', end_ = '^>>>>>>> ' },
      keys  = { [1] = 'l',     [2] = 'b',    [3] = 'r'      },
      names = { [1] = 'Local', [2] = 'Base', [3] = 'Remote' },
    }
  else  -- git (2-block, no diff3)
    ctx = {
      vcs         = 'git',
      base_str    = 'Base',   remote_str = 'Remote',
      local_str   = 'Local',  merge_str  = 'Merged',
      three_block = false,
      P = { b1 = '^<<<<<<< ', b2 = '^=======', b3 = nil, end_ = '^>>>>>>> ' },
      keys  = { [1] = 'l',     [2] = 'r'      },
      names = { [1] = 'Local', [2] = 'Remote' },
    }
  end
  -- Build 'any' pattern for conflict_motion
  local parts = { ctx.P.b1, ctx.P.b2 }
  if ctx.P.b3 then parts[#parts + 1] = ctx.P.b3 end
  parts[#parts + 1] = ctx.P.end_
  ctx.P.any = table.concat(parts, [[\|]])
  -- Start pattern of the last content block (drives 'a' text-object end logic)
  ctx.P.last_start = ctx.P.b3 or ctx.P.b2
end

-- Jump to next (fwd=true) or previous (fwd=false) conflict marker
local function conflict_motion(fwd, extra_flags)
  local flags = 'W' .. (fwd and '' or 'b') .. (extra_flags or '')
  return vim.fn.search([[\M]] .. ctx.P.any, flags)
end

-- Find line numbers of all markers in the conflict block containing the cursor.
-- Returns nil if not in a valid conflict block. Does not move the cursor.
local function find_conflict_block()
  local P = ctx.P
  local saved = vim.fn.getcurpos()
  local b1 = vim.fn.search([[\M]] .. P.b1, 'bWc')  -- temporarily move to b1 so forward searches below are anchored correctly
  if b1 == 0 then vim.fn.setpos('.', saved); return nil end
  local b2   = vim.fn.search([[\M]] .. P.b2,  'Wcn')
  local b3   = P.b3 and vim.fn.search([[\M]] .. P.b3, 'Wcn') or nil
  local end_ = vim.fn.search([[\M]] .. P.end_, 'Wcn')
  vim.fn.setpos('.', saved)
  if b2 == 0 or end_ == 0 then return nil end
  if ctx.three_block then
    if b3 == 0 or not (b1 < b2 and b2 < b3 and b3 < end_) then return nil end
  else
    if not (b1 < b2 and b2 < end_) then return nil end
  end
  return { b1 = b1, b2 = b2, b3 = b3, end_ = end_ }
end

-- Text object for conflict blocks.
-- ai:        'i' (inner, excludes markers) or 'a' (around, includes markers)
-- block_num: 1, 2, or 3 for a specific block; nil for the whole conflict block
local function conflict_text_obj(ai, block_num)
  local curpos = vim.fn.getcurpos()
  local P = ctx.P

  -- Step off the end marker if cursor is on it
  if vim.fn.match(vim.fn.getline('.'), [[\M]] .. P.end_) >= 0 then
    vim.cmd('normal! k')
  end

  -- Enclosing conflict bounds (for search clamping)
  local first_line = vim.fn.search([[\M]] .. P.b1,  'bWcn')
  local last_line  = vim.fn.search([[\M]] .. P.end_, 'Wcn')
  if last_line == 0 then last_line = vim.fn.line('$') end

  -- Determine start/end search patterns and whether this is the last block
  local start_pat, end_pat
  local is_last_block = false

  if block_num == 1 then
    start_pat = [[\M]] .. P.b1
    end_pat   = [[\M]] .. P.b2
  elseif block_num == 2 and ctx.three_block then
    start_pat = [[\M]] .. P.b2
    end_pat   = [[\M]] .. P.b3
  elseif block_num == 3 or (block_num == 2 and not ctx.three_block) then
    start_pat     = [[\M]] .. P.last_start
    end_pat       = [[\M]] .. P.end_
    is_last_block = true
  else  -- whole block
    local s = P.b1 .. [[\|]] .. P.b2
    if P.b3 then s = s .. [[\|]] .. P.b3 end
    start_pat = [[\M]] .. s
    local e = P.b2
    if P.b3 then e = e .. [[\|]] .. P.b3 end
    end_pat = [[\M]] .. e .. [[\|]] .. P.end_
  end

  -- Find start: backward first, then forward
  local start = vim.fn.search(start_pat, 'bWc', first_line)
  if start == 0 then start = vim.fn.search(start_pat, 'Wc', last_line) end
  if start == 0 then
    vim.notify('Not in a conflict block', vim.log.levels.ERROR)
    vim.fn.setpos('.', curpos)
    return
  end

  -- For whole-block text objects, determine last-block status from cursor position
  if block_num == nil then
    is_last_block = vim.fn.match(vim.fn.getline(start), [[\M]] .. P.last_start) >= 0
  end

  -- Find end: forward first, then backward
  local end_ = vim.fn.search(end_pat, 'Wn', last_line)
  if end_ == 0 then
    end_ = is_last_block and vim.fn.line('$')
               or vim.fn.search(end_pat, 'bWn', first_line)
  end
  if end_ == 0 then
    vim.notify('Unable to find end of conflict block', vim.log.levels.ERROR)
    vim.fn.setpos('.', curpos)
    return
  end

  -- Adjust range: 'i' excludes markers; 'a' on the last block keeps the closing marker
  if ai == 'i' then
    start = start + 1
    end_  = end_ - 1
  elseif not is_last_block then
    end_ = end_ - 1
  end

  if start > end_ then
    vim.notify('Conflict block bounds are invalid', vim.log.levels.ERROR)
    vim.fn.setpos('.', curpos)
    return
  end

  vim.fn.cursor(start, 1)
  vim.cmd('normal! V' .. (end_ > start and (end_ - start) .. 'j' or ''))
end

-- Accept one block: delete all other sections and their markers.
-- Uses bottom-up deletion to preserve line numbers.
local function diff_get(block_num)
  local b = find_conflict_block()
  if not b then
    vim.notify('Not in a conflict block', vim.log.levels.ERROR)
    return
  end

  if block_num == 1 then
    -- Keep b1+1..b2-1
    vim.cmd(b.b2  .. ',' .. b.end_ .. 'delete _')
    vim.cmd(b.b1  ..                  'delete _')
  elseif block_num == 2 and ctx.three_block then
    -- Keep b2+1..b3-1
    vim.cmd(b.b3  .. ',' .. b.end_ .. 'delete _')
    vim.cmd(b.b1  .. ',' .. b.b2   .. 'delete _')
  else
    -- Last block: keep last_start+1..end_-1
    local last_start = b.b3 or b.b2
    vim.cmd(b.end_        ..                   'delete _')
    vim.cmd(b.b1  .. ',' .. last_start .. 'delete _')
  end
end

-- Set up keymaps, buffer-local to the merge file
local function create_merge_maps(bufnr)
  local function o(desc)
    return { silent = true, buffer = bufnr, desc = desc }
  end

  vim.keymap.set({ 'n', 'x', 'o' }, '[C', function() conflict_motion(false) end, o('Prev conflict marker'))
  vim.keymap.set({ 'n', 'x', 'o' }, ']C', function() conflict_motion(true) end,  o('Next conflict marker'))
  -- Whole-block text objects
  for _, ai in ipairs({ 'i', 'a' }) do
    for _, mode in ipairs({ 'o', 'x' }) do
      local desc = (ai == 'i' and 'Inner' or 'Around') .. ' conflict block'
      vim.keymap.set(mode, ai .. 'C', function() conflict_text_obj(ai, nil) end, o(desc))
    end
  end

  -- Per-block text objects and diff_get keymaps
  for _, n in ipairs(ctx.three_block and { 1, 2, 3 } or { 1, 2 }) do
    local key, name = ctx.keys[n], ctx.names[n]
    for _, ai in ipairs({ 'i', 'a' }) do
      for _, mode in ipairs({ 'o', 'x' }) do
        local desc = (ai == 'i' and 'Inner' or 'Around') .. ' ' .. name .. ' block'
        vim.keymap.set(mode, ai .. key .. 'C', function() conflict_text_obj(ai, n) end, o(desc))
      end
    end
    vim.keymap.set('n', 'dg' .. key, function() diff_get(n) end, o('Accept ' .. name))
  end
end

-- Helper: open a two-window diff tab using buffer numbers (avoids path-matching issues)
local function diff_tab(label, file_a, file_b)
  local bna = vim.fn.bufnr(file_a)
  local bnb = vim.fn.bufnr(file_b)
  vim.cmd('silent! tabe | silent! b ' .. bna)
  vim.cmd('silent! wincmd v | silent! b ' .. bnb)
  vim.cmd('silent! windo diffthis')
  vim.t.guitablabel = label
end

-- Set up the full 7-tab merge layout
local function setup_merge_layout()
  local base   = vim.fn.argv(0)
  local remote = vim.fn.argv(1)
  local local_ = vim.fn.argv(2)
  local merged = vim.fn.argv(3)
  local B, R, L, M = ctx.base_str, ctx.remote_str, ctx.local_str, ctx.merge_str

  vim.cmd('silent! tabonly | silent! wincmd o')

  -- Tab 1 (Main): BASE | REMOTE | LOCAL on top, MERGED on bottom
  vim.cmd('silent! b ' .. vim.fn.fnameescape(merged))
  vim.bo.readonly   = false
  vim.bo.modifiable = true
  vim.b.bufname     = M:upper()
  vim.cmd('silent! wincmd s')   -- split: merged to bottom
  vim.cmd('silent! wincmd t')   -- move to top-left
  vim.cmd('silent! b ' .. vim.fn.fnameescape(base))   ; vim.b.bufname = B:upper()
  vim.cmd('silent! wincmd v')
  vim.cmd('silent! b ' .. vim.fn.fnameescape(remote)) ; vim.b.bufname = R:upper()
  vim.cmd('silent! wincmd v')
  vim.cmd('silent! b ' .. vim.fn.fnameescape(local_)) ; vim.b.bufname = L:upper()
  vim.bo.readonly = true
  vim.cmd('silent! windo diffthis')
  vim.t.guitablabel = 'Main'

  -- Tab 2: REMOTE | MERGED | LOCAL (3-way)
  vim.cmd('silent! tabe | silent! b ' .. vim.fn.bufnr(remote))
  vim.cmd('silent! wincmd v | silent! b ' .. vim.fn.bufnr(merged))
  vim.cmd('silent! wincmd v | silent! b ' .. vim.fn.bufnr(local_))
  vim.cmd('silent! windo diffthis | silent! wincmd h')
  vim.t.guitablabel = R .. ' v/s ' .. M .. ' v/s ' .. L

  -- Tabs 3–7: pairwise diffs
  diff_tab(L .. ' v/s ' .. M, local_, merged)
  diff_tab(R .. ' v/s ' .. M, remote, merged)
  diff_tab(B .. ' v/s ' .. R, base,   remote)
  diff_tab(B .. ' v/s ' .. L, base,   local_)
  diff_tab(R .. ' v/s ' .. L, remote, local_)

  vim.cmd('silent! tabdo wincmd = | silent! tabfirst')
end

-- Entry point
local function merge_init()
  if vim.fn.argc() < 4 then
    vim.notify('MergeInit requires 4 arguments: base remote local merged', vim.log.levels.ERROR)
    return
  end
  local merged_file = vim.fn.argv(3)
  local vcs = detect_vcs(merged_file)
  setup_ctx(vcs)
  vim.notify('Merge mode: ' .. vcs, vim.log.levels.INFO)
  setup_merge_layout()
  -- Navigate to the merge buffer (bottom split of tab 1) and set keymaps there
  vim.cmd('wincmd b')
  create_merge_maps(vim.api.nvim_get_current_buf())
end

return {
  {
    'LazyVim/LazyVim',
    init = function()
      vim.api.nvim_create_user_command('MergeInit', merge_init, {
        desc = 'Initialize 4-way merge layout (auto-detects Perforce/Git)',
      })
    end,
  },
}
