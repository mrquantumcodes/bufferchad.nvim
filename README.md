# BufferChad

An simple, customisable Buffer Manager for Neovim that `just works` out of the box

## Installation and setup

Install using your favourite package manager. Here's how to install BufferChad with `Packer`:

```lua
use {
    "mrquantumcodes/bufferchad.nvim",
    requires = {
        {"nvim-lua/plenary.nvim"},
        {"MunifTanjim/nui.nvim"},
        {"stevearc/dressing.nvim"},
        {"nvim-telescope/telescope.nvim"} -- needed for fuzzy search, but should work fine even without it
    }
}
```

Next, add the following lines to your `index.lua`:

```lua
require("bufferchad").setup({
  mapping = "<leader>bb", -- Map any key, or set to NONE to disable key mapping
  order = "LAST_USED_UP" -- LAST_USED_UP (default)/ASCENDING/DESCENDING/REGULAR
})
```

## Configuration options

Change the mapping to anything you like, I recommend "<leader>bb".

The order parameter can have the following arguments:

* **LAST_USED_UP** sorts buffers by descending order of usage (most recent buffers shown first), but puts the previously used buffer in first place. Recommended option for working on two main buffers.

* **REGULAR** shows buffers in the order returned by ":ls" command.

* **DESCENDING** sorts buffers by descending order of usage (most recent buffers shown first)

* **ASCENDING** sorts buffers by ascending order of usage (most recent buffers shown last)