# goto-test.nvim

Go to test for your current file.

## Getting Started
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
			"<cmd>:GotoTest<cr>",
		},
	},
}
```

Otherwise you can register a normal keymap that calls this command:
```lua
vim.keymap.set('n', '<leader>gt', '<cmd>:GotoTest<cr>', { noremap = true, silent = true })
```

## Configuration
The plugin has a list of file path patterns that is searches during location of the test file.

If you are using some non standard folder structure you can supply your own path using glob pattern.

You can also use two additional values in the patterns:
- `{filename}` required - this value will be replaced by current filename.
- `{pwd}` optional - current file directory - useful if your test files are in the same directory as your source code.

```lua
{
    "LasEmil/goto-test.nvim",
    lazy = true,
    opts = {
        patterns = {
            "java/**/{filename}__Test.*",
            "{pwd}/{filename}.__test__.*",
        },
    },
}
```
