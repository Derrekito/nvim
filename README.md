# nvim

My Neovim configuration. C++ first, with LaTeX, Markdown, and Lua along for the
ride. Managed with [lazy.nvim](https://lazy.folke.io).

## Requirements

Neovim 0.11 or newer, since per-server LSP setup goes through `vim.lsp.config`.
Developed on 0.12.

Language servers install themselves. Mason is pinned to `clangd`,
`rust_analyzer`, `bashls`, `lua_ls`, `marksman`, `pylsp`, `jsonls`, and
`texlab`, and enables them automatically on first launch.

One exception: `cmake-language-server` comes from pipx and is expected on
`PATH`. Its virtualenv needs `pygls>=1.1.1,<2.0`, because pygls 2.x dropped the
import that server relies on.

## Layout

```
init.lua              entry point; ordered requires, nothing else
lua/config/lazy.lua   lazy.nvim bootstrap and global plugin options
lua/config/keymaps.lua
lua/config/options.lua
lua/config/autocmds.lua
lua/plugins/          one file per plugin spec
after/ftplugin/       per-filetype settings
queries/              treesitter query overrides
```

Load order in `init.lua` is deliberate. Keymaps run first because they set the
leader key, which lazy.nvim needs before it registers any plugin `keys` spec.
Options run after plugins so they override plugin defaults. Autocommands and
diagnostics run last.

## Install

```bash
git clone https://github.com/Derrekito/nvim ~/.config/nvim
nvim
```

Plugins install on first launch.

Two of the plugins are mine, [devdocs.nvim](https://github.com/Derrekito/devdocs.nvim)
and [diagnostic-picker.nvim](https://github.com/Derrekito/diagnostic-picker.nvim).
They install from GitHub like anything else. On a machine where a local checkout
exists under `~/devel` or `~/Projects`, lazy.nvim uses that instead, so edits are
live. See the `dev` block in `lua/config/lazy.lua`.

## Colors

[Rosé Pine Moon](https://rosepinetheme.com), with a local palette override in
`lua/rose-pine-moon.lua`.
