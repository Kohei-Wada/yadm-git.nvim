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

## Configuration (Options)

| Option | Type    | Default | Description                       |
| ------ | ------- | ------- | --------------------------------- |
| debug  | boolean | false   | Enable debug logging (vim.notify) |

## Usage

Open Neovim in your home directory (or any directory managed by yadm) and the plugin will automatically set `GIT_DIR` and `GIT_WORK_TREE`. This ensures Git commands like `:Gstatus` and `:Gdiff` operate on your dotfiles repository.

## Contributing

Bug reports and pull requests are welcome!
