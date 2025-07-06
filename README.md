# yadm-git.nvim

yadm-git.nvim is a lightweight Neovim plugin that enables you to use Neovim's built-in Git features to manage your dotfiles (home directory) tracked by [yadm](https://yadm.io).

## What this plugin does

This plugin automatically detects if you're editing files under yadm's control
(e.g. `$HOME/.config`, `$HOME/.bashrc`, etc.), and sets appropriate Git
environment variables so that Git-based plugins (like `gitsigns.nvim`, `fugitive`,
`lazygit.nvim`, etc.) can function properly within the yadm repository.

No commands. No user interaction. It just works.

## Requirements

- Neovim 0.10 or later
- [yadm](https://yadm.io) must be installed and initialized

## Installation

### packer.nvim

```lua
use {
  'Kohei-Wada/yadm-git.nvim',
  config = function()
    require('yadm-git').setup({
      debug = true, -- Enable debug logging (default: false)
    })
  end,
}
```

### vim-plug

```vim
Plug 'Kohei-Wada/yadm-git.nvim'
```

```lua
-- init.lua or vimrc
require('yadm-git').setup({
  debug = false,
})
```

### lazy.nvim

```lua
return {
  "Kohei-Wada/yadm-git.nvim",
  lazy = true,
  event = "VeryLazy",
}
```

## Configuration (Options)

| Option | Type    | Default | Description                       |
| ------ | ------- | ------- | --------------------------------- |
| debug  | boolean | false   | Enable debug logging (vim.notify) |

## Usage

Open Neovim in your home directory (or any directory managed by yadm) and the plugin will automatically set `GIT_DIR` and `GIT_WORK_TREE`. This ensures Git commands like `:Gstatus` and `:Gdiff` operate on your dotfiles repository.

## API

The plugin provides the following API functions to interact with its state:

### `is_active()`

Check if the plugin is currently active (yadm environment is set up).

```lua
local is_active = require('yadm-git').is_active()
if is_active then
  print("yadm-git is active")
end
```

**Returns:** `boolean` - `true` if the plugin is active, `false` otherwise

### `get_yadm_repo_path()`

Get the path to the yadm repository if the plugin is active.

```lua
local repo_path = require('yadm-git').get_yadm_repo_path()
if repo_path then
  print("yadm repository is at: " .. repo_path)
end
```

**Returns:** `string|nil` - Path to the yadm repository, or `nil` if not active

### `get_state()`

Get the current plugin state.

```lua
local state = require('yadm-git').get_state()
print("Active: " .. tostring(state.is_active))
print("Repo path: " .. (state.yadm_repo_path or "none"))
```

**Returns:** `table` - A table containing:
- `is_active` (boolean): Whether the plugin is currently active
- `yadm_repo_path` (string|nil): Path to the yadm repository, or `nil` if not active

## Contributing

Bug reports and pull requests are welcome!
