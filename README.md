# goto-test.nvim
### 🚧 Work In Progress 🚧
Go to test for your current file or outer function.

### Features
- Search for a test file for an outer function under a cursor.
- Search using [fd](https://github.com/sharkdp/fd) if LSP search fails.
- Opens files in QuickFix list if there is more than one result.
- Configurable search patterns.

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
    lazy = true,
    "LasEmil/goto-test.nvim",
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
The plugin has a list of patterns for matching test files:
```lua
local test_patterns = {
    "**/{filename}.test.*",
    "**/{filename}_test.*",
    "**/test_{filename}.*",
    "**/{filename}.spec.*"
}
```

If you are using some non standard test filename pattern you can supply your own path using glob pattern.

In the pattern you have to use a special value for the filename:

- `{filename}` required - this value will be replaced by current filename in case LSP search fails and we are using fd fallback.

```lua
{
    "LasEmil/goto-test.nvim",
    lazy = true,
    opts = {
        patterns = {
            "**/{filename}.testsuite.*",
        },
    }
}
```

## Todo
- Add tests, that's weird that a plugin for finding test files doesn't have any tests
