-- Entry point. Everything lives under lua/config/; plugin specs under lua/plugins/.
--
-- Load order is deliberate:
--   1. keymaps   sets <leader>, which lazy.nvim needs before it registers any
--                plugin `keys = {}` spec.
--   2. lazy      bootstraps the plugin manager and loads lua/plugins/*.
--   3. options   after plugins, so our settings override plugin defaults.
--   4. lsp-*     compat shim and autorestart hook into LspAttach.
--   5. autocmds  diagnostics config + user autocmds, last so nothing clobbers it.
require("config.keymaps")
require("config.lazy")
require("config.options")
require("lsp-autorestart")
require("lsp-compat-shim").setup()
require("config.autocmds")
