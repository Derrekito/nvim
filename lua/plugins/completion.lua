-- ~/.config/nvim/lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        window = {
          documentation = cmp.config.window.bordered(),
          completion = cmp.config.window.bordered(),
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
          }),
          ["<Tab>"] = cmp.mapping.select_next_item(), -- Added for convenience
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "orgmode" },
          { name = "path" },
          {
            name = "buffer",
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end,
            }
          },
        }),
      })
      -- Command-line setups
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } },
        }),
      })
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure lua_ls to only use .config/nvim as workspace for config files
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local config_dir = vim.fn.stdpath("config")
          if fname:match("^" .. vim.pesc(config_dir)) then
            on_dir(config_dir)
            return
          end
          on_dir(vim.fs.root(fname, {".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git"}))
        end,
      })

      -- Marksman: pin root to a real vault/project, never $HOME.
      -- Default behavior walks up to $HOME and recurses every .md file
      -- under it, which hits symlink loops in Steam Proton wine prefixes
      -- (~/.local/share/Steam/.../dosdevices/z: → /) and crashes the server.
      vim.lsp.config("marksman", {
        capabilities = capabilities,
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local home = vim.uv.os_homedir() or os.getenv("HOME")
          local root = vim.fs.root(fname, { ".marksman.toml", ".git", ".obsidian" })
          -- Refuse $HOME (or its parents) as a root; fall back to the
          -- file's own directory so marksman scans nothing else.
          if not root or root == home or #root <= #home then
            root = vim.fs.dirname(fname)
          end
          on_dir(root)
        end,
      })

      local servers = {
        "clangd", "rust_analyzer", "bashls", "lua_ls",
        "marksman", "pylsp", "jsonls", "texlab",
      }
      for _, server in ipairs(servers) do
        if server == "clangd" then
          vim.lsp.config(server, {
            capabilities = capabilities,
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--header-insertion-decorators",
            },
            -- Disable clangd's LSP semantic tokens so treesitter highlighting
            -- always wins. clangd's semantic highlighting layers on top of
            -- treesitter only after it resolves a file (needs the right
            -- headers / compile_commands.json), which made std::/type colors
            -- inconsistent: foam when resolved, plain when not. Dropping the
            -- provider makes highlighting grammar-based, instant, consistent.
            on_attach = function(client, _)
              client.server_capabilities.semanticTokensProvider = nil
            end,
          })
        elseif server ~= "lua_ls" and server ~= "marksman" then
          vim.lsp.config(server, { capabilities = capabilities })
        end
      end
      vim.lsp.enable(servers)
      -- LSP keybindings (gd, K, <leader>rn, etc.) are defined in init.lua's
      -- LspAttach autocmd. They were duplicated here, and this autocmd's K
      -- (plain hover, no float opts) raced with init.lua's wider/wrapping K —
      -- whichever attached last won, so hover was intermittently too narrow.
      -- Removed to make init.lua the single source of truth.
    end,
  },
}
