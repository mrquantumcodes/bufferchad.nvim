# Changelog

All notable changes to BufferChad will be documented in this file.

## [2.0.0] - 2025-01-05

### 🔥 Major Features

#### New Fuzzy Finder Mode
- **Lightning-fast fuzzy matching** with intelligent scoring algorithm
  - Sequential character bonus (matching "abc" scores higher when letters are adjacent)
  - Separator bonus (matches after `/`, `-`, `_` score higher)
  - CamelCase bonus (matches at word boundaries)
  - First letter bonus
  - Smart penalty system for leading unmatched characters
- **Live file preview** with full syntax highlighting
  - Preview updates instantly as you navigate results
  - Configurable preview size and line count
  - Preview caching for performance
- **Beautiful UI with icons**
  - File icons via nvim-web-devicons (optional)
  - Color-coded icons matching file types
  - Match highlighting shows exactly what matched your query
  - Custom highlight groups for all UI elements
- **Intuitive keybindings**
  - `Ctrl-n/p` or arrow keys for navigation
  - `Enter` to select
  - `Esc` or `Ctrl-c` to close
  - `j/k` navigation when focused on results

### 🚀 Core Improvements

#### Modern Neovim API (0.11+ Ready)
- **Removed deprecated APIs**
  - `vim.loop` → `vim.uv` (libuv bindings)
  - Fixed all keymap APIs to use `vim.keymap.set()` properly
  - Fixed callback execution bugs in keybindings
- **Better buffer detection**
  - Replaced `:ls` command parsing with `nvim_list_bufs()` API
  - Uses `nvim_buf_get_info()` for accurate buffer state
  - More reliable and significantly faster

#### Performance Optimizations
- **Marked buffer caching system**
  - Per-directory cache prevents repeated file I/O
  - Atomic cache+file writes for consistency
  - Dramatic speedup for mark operations
- **Modular architecture**
  - `lua/bufferchad/fuzzy.lua` - Fuzzy matching engine
  - `lua/bufferchad/preview.lua` - Preview system
  - `lua/bufferchad/ui.lua` - UI rendering
  - `lua/bufferchad/picker.lua` - Interactive picker
  - Clean separation of concerns, easy to extend

### 🎨 UI/UX Enhancements

- **Three UI styles**
  - `fuzzy` - New modern picker (recommended)
  - `default` - Simple native window
  - `telescope` - Telescope integration
- **Removed dressing.nvim dependency**
  - No longer needed for modern UI
  - Simpler dependency tree
- **Better highlight groups**
  - `BufferChadFuzzyMatch` - Fuzzy match highlights
  - `BufferChadBorder` - Window borders
  - `BufferChadTitle` - Window titles
  - `BufferChadPrompt` - Search prompt
  - `BufferChadSelection` - Selected item
  - `BufferChadPreviewBorder` - Preview border

### 🐛 Bug Fixes

- Fixed keymap callback execution (were being called immediately)
- Fixed buffer name path handling on Windows
- Fixed empty buffer filtering
- Fixed marked buffer persistence across sessions
- Improved error handling for unreadable files

### 📚 Documentation

- Complete rewrite of README with feature highlights
- Added example configuration file
- Updated all code examples for new API
- Added this CHANGELOG

### ⚠️ Breaking Changes

- **Removed `style = "modern"`** (used dressing.nvim)
  - Use `style = "fuzzy"` for modern UI instead
  - Old "modern" style users will fall back to "default"
- **Default style changed** from "modern" to "default"
  - Update your config to `style = "fuzzy"` for the new experience

### 🔧 Configuration Changes

New configuration options:
```lua
{
  style = "fuzzy",          -- NEW: fuzzy, default, or telescope
  show_preview = true,      -- NEW: enable/disable preview
  show_icons = true,        -- NEW: enable/disable icons
  preview_lines = 10,       -- NEW: preview size
  picker_width = 80,        -- NEW: picker width
  picker_height = 20,       -- NEW: picker height
  preview_width = 60,       -- NEW: preview width
}
```

Removed options:
- `style = "modern"` (removed with dressing.nvim support)

---

## [1.x] - Previous versions

See git history for older changes before the v2.0 rewrite.
