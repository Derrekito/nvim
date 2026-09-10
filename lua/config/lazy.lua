-- Bootstrap lazy.nvim and load every spec under lua/plugins/.
-- Mirrors the upstream installation recipe: https://lazy.folke.io/installation
--
-- <leader> must already be set when this runs, or plugin `keys = {}` specs
-- register against the wrong prefix. init.lua requires config.keymaps first.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- latest stable release
    lazyrepo,
    lazypath,
  })
  -- Without this check a failed clone (no network, or a corporate TLS-inspecting
  -- proxy whose CA isn't in the system trust store) still falls through to the
  -- prepend below, and the next `require("lazy")` dies with a module-not-found
  -- error that says nothing about git. Show the actual clone output instead.
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- My own plugins are specced by their GitHub name so a fresh clone of this
  -- config installs them like any other. On a machine where I actually hack on
  -- them, the local checkout wins instead, so edits are live with no reinstall.
  -- `fallback` is what makes both true: no checkout, clone from GitHub.
  dev = {
    path = function(plugin)
      for _, root in ipairs({ "~/devel/", "~/Projects/" }) do
        local p = vim.fn.expand(root .. plugin.name)
        if vim.fn.isdirectory(p) == 1 then
          return p
        end
      end
      return vim.fn.expand("~/devel/" .. plugin.name)
    end,
    patterns = { "Derrekito" },
    fallback = true,
  },
  change_detection = {
    enabled = true,
    notify = true,
  },
})
