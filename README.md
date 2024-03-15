# BufferChad

An simple, customisable Buffer Manager for Neovim that `just works` out of the box

![App Screenshot](https://github.com/mrquantumcodes/bufferchad.nvim/blob/main/demo.gif)

# *What's new?
* Now, you no longer need to install `dressing.nvim` and `nui.nvim` like before, simply to use the plugin. If those plugins are not downloaded, buffers will be displayed using neovim's native window api and you can search buffers using the `slash (/)` key. If you do install Dressing and Nui, they will be automatically picked up and the Buffer Picker UI will change accordingly.
* Also, you can now mark files like `Harpoon` to quickly navigate between them.
* Telescope Integration

# *What's New-NEW?
* Marked buffer list can now be edited like a normal buffer, just like Harpoon
* Marked buffers now persist across sessions (or different working directories in general), just like Harpoon
* There is a new, basic api to navigate to any marked buffer without opening the buffer list, just like Harpoon

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
  order = "LAST_USED_UP", -- LAST_USED_UP (default)/ASCENDING/DESCENDING/REGULAR
  style = "default", -- default, modern (requires dressing.nvim and nui.nvim), telescope (requires telescope.nvim)
  close_mapping = "<Esc><Esc>", -- only for the default style window. 
  normal_editor_mapping = "NONE" -- read use case below
})
```

## Configuration options

Change the mapping to anything you like, I recommend `<leader>bb` for listing all buffers and `<leader>bm` for listing marked buffers.

*NOTE:* The `normal_editor_mapping` parameter, while optional, is required to be able to edit the indexes of marked buffers. If you want to change your marked buffers, such as reordering them, but you wanna use telescope or modern style for your core ui, then you need to use this parameter, because for now, only the normal style buffer list ui supports editing of it's contents.

The order parameter can have the following arguments:

* **LAST_USED_UP** sorts buffers by descending order of usage (most recent buffers shown first), but puts the previously used buffer in first place. Recommended option for working on two main buffers.

* **REGULAR** shows buffers in the order returned by ":ls" command.

* **DESCENDING** sorts buffers by descending order of usage (most recent buffers shown first)

* **ASCENDING** sorts buffers by ascending order of usage (most recent buffers shown last)

# File Marking

Now, BufferChad allows you to mark files like the `Harpoon` plugin. This let's you quickly switch between specific files instead of going through a list of all the buffers you have used till now.

Use the `mset` keymap to mark the current file in the last position of the register, or `<1-9>set` to mark the current file the location of your choice. Then, to navigate, you can use either of the following options:
* `require("bufferchad").nav_to_marked(MARK_NUMBER)` (replace MARK_NUMBER with your mark number) to navigate to that mark.
* Use your marks list using the `mark_mapping` or the `normal_editor_mapping` keybinding.

Use your `mark_mapping` (default is `<leader>bm`) keymap to view your marks list
