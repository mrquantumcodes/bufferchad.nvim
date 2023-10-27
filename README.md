# BufferChad

An simple, customisable Buffer Manager for Neovim that `just works` out of the box

![App Screenshot](https://github.com/mrquantumcodes/bufferchad.nvim/blob/main/demo.gif)

# *What's new?
* Now, you no longer need to install `dressing.nvim` and `nui.nvim` like before, simply to use the plugin. If those plugins are not downloaded, buffers will be displayed using neovim's native window api and you can search buffers using the `slash (/)` key. If you do install Dressing and Nui, they will be automatically picked up and the Buffer Picker UI will change accordingly.
* Also, you can now mark files like `Harpoon` to quickly navigate between them.

## Installation and setup

Install using your favourite package manager. Here's how to install BufferChad with `Packer`:

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

Next, add the following lines to your `index.lua`:

```lua
require("bufferchad").setup({
  mapping = "<leader>bb", -- Map any key, or set to NONE to disable key mapping
  mark_mapping = "<leader>bm", -- The keybinding to display just the marked buffers
  order = "LAST_USED_UP", -- LAST_USED_UP (default)/ASCENDING/DESCENDING/REGULAR
  style = "default" -- default, modern (requires dressing.nvim and nui.nvim), telescope (requires telescope.nvim)
})
```

## Configuration options

Change the mapping to anything you like, I recommend `<leader>bb` for listing all buffers and `<leader>bm` for listing marked buffers.

The order parameter can have the following arguments:

* **LAST_USED_UP** sorts buffers by descending order of usage (most recent buffers shown first), but puts the previously used buffer in first place. Recommended option for working on two main buffers.

* **REGULAR** shows buffers in the order returned by ":ls" command.

* **DESCENDING** sorts buffers by descending order of usage (most recent buffers shown first)

* **ASCENDING** sorts buffers by ascending order of usage (most recent buffers shown last)

# File Marking

Now, BufferChad allows you to mark files like the `Harpoon` plugin. This let's you quickly switch between specific files instead of going through a list of all the buffers you have used till now.

Use the `mset` keymap to mark the current file in the last position of the register, or `<1-9>set` to mark the current file the location of your choice. Then, use `<1-9>nav` to quickly navigate to that buffer. For example:
* `5set` to set this buffer to the 5th position.
* `5nav` to navigate to the buffer in that position.

Use the `mdel` keymap to delete the current buffer from marks list

Use your `mark_mapping` (default is `<leader>bm`) keymap to view your marks list

__Note:__ If you enter a number greater than the number of already marked elements, say trying to mark a buffer to index 5 when only 3 buffers have been marked previously, the current buffer will be marked to index 4 instead of 5.

__**NOTE:__ The `<1-9>set` mapping is somewhat unpredictable currently and can lead to duplicate marks. This will be fixed soon.