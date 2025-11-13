-- Example BufferChad Configuration
-- Copy this to your Neovim config and customize as needed

require("bufferchad").setup({
  -- ============================================================================
  -- KEYBINDINGS
  -- ============================================================================
  mapping = "<leader>bb",           -- Main buffer list keybinding
  mark_mapping = "<leader>bm",      -- Marked buffers keybinding
  add_mark_mapping = "mset",        -- Add current buffer to marks
  switcher_mapping = "<C-Tab>",     -- VSCode-style buffer switcher (Ctrl+Tab)
  close_mapping = "<Esc><Esc>",     -- Close picker (default style only)
  normal_editor_mapping = "NONE",   -- Direct editor for marks (optional)

  -- ============================================================================
  -- UI STYLE (choose one)
  -- ============================================================================
  -- Option 1: Fuzzy (RECOMMENDED) - Modern fuzzy finder with preview
  style = "fuzzy",

  -- Option 2: Default - Simple native window
  -- style = "default",

  -- Option 3: Telescope - Requires telescope.nvim
  -- style = "telescope",

  -- ============================================================================
  -- FUZZY MODE OPTIONS (only applies when style = "fuzzy")
  -- ============================================================================
  show_preview = true,              -- Show file preview
  show_icons = true,                -- Show file icons (requires nvim-web-devicons)
  preview_lines = 10,               -- Lines to show in preview
  picker_width = 80,                -- Width of fuzzy picker
  picker_height = 20,               -- Height of fuzzy picker
  preview_width = 60,               -- Width of preview window

  -- ============================================================================
  -- BUFFER SORTING
  -- ============================================================================
  -- LAST_USED_UP: Most recent first, but swap top 2 (great for toggling)
  -- DESCENDING: Most recent first
  -- ASCENDING: Least recent first
  -- REGULAR: Native :ls order
  order = "LAST_USED_UP",
})

-- ============================================================================
-- ADDITIONAL KEYBINDINGS (optional)
-- ============================================================================

-- Quick navigation to marked buffers (Harpoon-style)
vim.keymap.set('n', '<leader>1', function() require('bufferchad').nav_to_marked(1) end)
vim.keymap.set('n', '<leader>2', function() require('bufferchad').nav_to_marked(2) end)
vim.keymap.set('n', '<leader>3', function() require('bufferchad').nav_to_marked(3) end)
vim.keymap.set('n', '<leader>4', function() require('bufferchad').nav_to_marked(4) end)
vim.keymap.set('n', '<leader>5', function() require('bufferchad').nav_to_marked(5) end)

-- Alternative: Use a loop for all 9 marks
-- for i = 1, 9 do
--   vim.keymap.set('n', '<leader>' .. i, function()
--     require('bufferchad').nav_to_marked(i)
--   end)
-- end

-- ============================================================================
-- BUILT-IN KEYBINDINGS (automatically available)
-- ============================================================================
--
-- When fuzzy picker is open:
--   <C-n> or <Down>  - Next item
--   <C-p> or <Up>    - Previous item
--   <CR>             - Select item
--   <Esc> or <C-c>   - Close picker
--
-- VSCode-style switcher (Ctrl+Tab):
--   <C-Tab>          - Open switcher (shows MRU buffers)
--   <Tab>            - Cycle to next buffer (while holding Ctrl)
--   <S-Tab>          - Cycle to previous buffer (while holding Ctrl)
--   Release Ctrl     - Open selected buffer
--   <Esc>            - Cancel
--
-- Marking system:
--   mset             - Add current buffer to marks (default)
--   mdel             - Remove current buffer from marks
--   1set - 9set      - Add current buffer at specific position
--   1swap - 9swap    - Swap current buffer with mark at position
--   1nav - 9nav      - Navigate to mark at position
--
-- ============================================================================
-- MINIMAL CONFIGURATION (zero config mode)
-- ============================================================================
-- Just want it to work? Use this instead:
--
-- require("bufferchad").setup({})
--
-- This gives you:
-- - <leader>bb for buffer list
-- - <leader>bm for marked buffers
-- - "fuzzy" style with all defaults
-- - All features enabled
