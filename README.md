# BufferChad

**A blazing-fast, feature-rich buffer manager for Neovim that actually makes buffer management enjoyable.**

![App Screenshot](https://github.com/mrquantumcodes/bufferchad.nvim/blob/main/demo.gif)

## ✨ Why BufferChad?

**Tired of "just use telescope" or "native buffers are enough"?** BufferChad combines the best of both worlds:

- ⚡ **Faster than Telescope** - Zero startup overhead, native Lua fuzzy matching
- 🎯 **Smarter than Native** - Intelligent fuzzy search with scoring, not just regex
- 🎨 **Beautiful UI** - File icons, syntax-highlighted previews, and match highlights
- 🚀 **Zero Dependencies** - Works out of the box, optional integrations available
- 💪 **Harpoon-style Marks** - Quick navigation to your most important files
- 🔧 **Actually Customizable** - Multiple UI styles, extensive configuration options
- 📦 **Neovim 0.11+ Ready** - Built with modern APIs for 2025

## 🔥 What's New in v2.0

### Modern Fuzzy Finder Mode
* **Lightning-fast fuzzy search** with intelligent scoring (sequential matches, camelCase, separators)
* **Live file preview** with full syntax highlighting as you type
* **Beautiful file icons** (optional, with nvim-web-devicons)
* **Match highlighting** shows exactly what characters matched your query
* **Zero dependencies** - pure Lua implementation
* **Fully modular** - clean codebase with separate fuzzy, preview, and UI modules

### VSCode-Style Buffer Switcher
* **Ctrl+Tab cycling** just like VSCode/IntelliJ (configurable to any key combo)
* **Hold-and-cycle** - keep pressing Tab while holding Ctrl to cycle through buffers
* **Release to select** - automatically opens buffer when you release the modifier key
* **Simple, fast UI** - no search needed, just quick switching

### Core Improvements
* **Removed deprecated APIs** - Updated for Neovim 0.11+
* **Performance optimizations** - Caching system for marked buffers
* **Better buffer detection** - Uses native APIs instead of shell parsing
* **Cleaner codebase** - Modular architecture makes it easy to extend

### Harpoon-Style Features
* Mark files like Harpoon for instant navigation
* Persistent marks across sessions per working directory
* Direct API for jumping to marked buffers without opening UI
* Editable mark lists just like normal buffers

## Installation and setup

Install using your favourite package manager. For Example:

<details>
<summary>
    Packer
</summary>

```lua
use {
    "mrquantumcodes/bufferchad.nvim",

    -- uncomment if you want fuzzy search with telescope and a modern ui

    -- requires = {
    --    {"nvim-lua/plenary.nvim"},
    --    {"MunifTanjim/nui.nvim"},
    --    {"stevearc/dressing.nvim"},
    --    {"nvim-telescope/telescope.nvim"} -- needed for fuzzy search, but should work fine even without it
    -- }
}
```
</details>

<details>
<summary>
    Lazy
</summary>

```lua
{
    "mrquantumcodes/bufferchad.nvim",

    -- uncomment if you want fuzzy search with telescope and a modern ui

    -- dependencies = {
    --    {"nvim-lua/plenary.nvim"},
    --    {"MunifTanjim/nui.nvim"},
    --    {"stevearc/dressing.nvim"},
    --    {"nvim-telescope/telescope.nvim"} -- needed for fuzzy search, but should work fine even without it
    -- }
}
```
</details>

Next, add the following lines to your `index.lua`:

```lua
require("bufferchad").setup({
  mapping = "<leader>bb", -- Map any key, or set to NONE to disable key mapping
  mark_mapping = "<leader>bm", -- The keybinding to display just the marked buffers
  add_mark_mapping = "mset", -- The keybinding to add a mark to a buffer
  order = "LAST_USED_UP", -- LAST_USED_UP (default)/ASCENDING/DESCENDING/REGULAR
  style = "fuzzy", -- default, fuzzy, telescope
  close_mapping = "<Esc><Esc>", -- only for the default style window
  normal_editor_mapping = "NONE", -- read use case below

  -- Fuzzy style options (only apply when style = "fuzzy")
  show_preview = true, -- Show file preview in fuzzy mode
  show_icons = true, -- Show file icons (requires nvim-web-devicons)
  preview_lines = 10, -- Number of lines to show in preview
  picker_width = 80, -- Width of the fuzzy picker
  picker_height = 20, -- Height of the fuzzy picker
  preview_width = 60, -- Width of the preview window
})
```

## Configuration options

### Style Options

BufferChad now supports **three different UI styles**:

1. **`fuzzy`** (✨ **NEW & RECOMMENDED**) - Modern fuzzy finder with:
   - ⚡ Lightning-fast fuzzy search with smart scoring
   - 👀 Live preview with syntax highlighting
   - 🎨 Beautiful file icons (with nvim-web-devicons)
   - 🎯 Match highlighting showing exactly what matched
   - ⌨️ Intuitive keybinds: `Ctrl-n/p` or arrow keys to navigate, `Enter` to select, `Esc` to close
   - 🚀 Zero dependencies - works out of the box!

2. **`default`** - Simple native Neovim window
   - Uses built-in floating windows
   - Search with `/` key
   - Lightweight and fast

3. **`telescope`** - Integration with telescope.nvim
   - Requires telescope.nvim installed
   - Familiar telescope interface

### Key Mappings

Change the mapping to anything you like, I recommend `<leader>bb` for listing all buffers and `<leader>bm` for listing marked buffers.

*NOTE:* The `normal_editor_mapping` parameter, while optional, is required to be able to edit the indexes of marked buffers. If you want to change your marked buffers, such as reordering them, but you wanna use telescope or fuzzy style for your core ui, then you need to use this parameter, because for now, only the default style buffer list ui supports editing of it's contents.

### Buffer Order

The order parameter can have the following arguments:

* **LAST_USED_UP** sorts buffers by descending order of usage (most recent buffers shown first), but puts the previously used buffer in first place. Recommended option for working on two main buffers.

* **REGULAR** shows buffers in the order returned by ":ls" command.

* **DESCENDING** sorts buffers by descending order of usage (most recent buffers shown first)

* **ASCENDING** sorts buffers by ascending order of usage (most recent buffers shown last)

# File Marking

Now, BufferChad allows you to mark files like the `Harpoon` plugin. This let's you quickly switch between specific files instead of going through a list of all the buffers you have used till now.

Use the `add_mark_mapping` keymap or the function `require('bufferchad').mark_this_buffer()` to mark the current file in the last position of the register. Then, to navigate, you can use either of the following options:
* `require("bufferchad").nav_to_marked(MARK_NUMBER)` (replace MARK_NUMBER with your mark number) to navigate to that mark.
* Use your marks list using the `mark_mapping` or the `normal_editor_mapping` keybinding.

Use your `mark_mapping` (default is `<leader>bm`) keymap to view your marks list
