# goto-test.nvim

Go to test for your current file.

### Requirements
- [fd](https://github.com/sharkdp/fd)
- Neovim >= 0.10.0

### Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim)

When using lazy there is no need to call setup function.

```lua
{
    "LasEmil/goto-test.nvim",
    lazy = true
}
```

When using any other package manager you have to call the setup function:

```lua
require("goto-test").setup()
```

## Usage
The plugin registers a command `:GotoTest`

If using [lazy.nvim](https://github.com/folke/lazy.nvim) and [which-key.nvim](https://github.com/folke/which-key.nvim) you can set up a key in lazy:

```lua
{
    "LasEmil/goto-test.nvim",
    lazy = true,
	keys = {
		{
			"<leader>gt",
			"<cmd>GotoTest<cr>",
		},
	},
}
```

Otherwise you can register a normal keymap that calls this command:
```lua
vim.keymap.set('n', '<leader>gt', '<cmd>GotoTest<cr>', { noremap = true, silent = true })
```

## Configuration
The plugin has a list of file path patterns that is searches during location of the test file.

If you are using some non standard folder structure you can supply your own path using glob pattern.

In the pattern you have to use a special value for the filename:

- `{filename}` required - this value will be replaced by current filename.

```lua
{
    "LasEmil/goto-test.nvim",
    lazy = true,
    opts = {
	patterns = {

		"{filename}.testsuite.*",
	},
    },
}
```

