return {
  -- Mason configuration for LSP server management
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    lazy = false,
    config = function()
      -- mason-lspconfig v2.x: this plugin now only handles install + auto-enable.
      -- The old `handlers` API was removed; per-server config goes through the
      -- native vim.lsp.config() API (Neovim 0.11+) below.
      require("mason-lspconfig").setup {
        ensure_installed = { 'clangd', 'rust_analyzer', 'bashls', 'lua_ls', 'marksman', 'pylsp', 'jsonls', 'texlab' },
        automatic_enable = true,
      }

      -- Per-server overrides. These merge over the defaults that nvim-lspconfig
      -- ships (cmd, filetypes, root_markers), and automatic_enable picks them up.
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--suggest-missing-includes",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--header-insertion-decorators",
        },
        -- Pin root resolution to project markers (most-specific first) so clangd
        -- anchors at the project dir, not $HOME. Without this, 0.12's default
        -- fell back to ~ and clangd (plus the diagnostic-picker's .clangd writes)
        -- rooted in the home directory.
        root_markers = {
          "compile_commands.json",
          ".clangd",
          "compile_flags.txt",
          ".git",
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim', 'bufnr' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true), -- include nvim runtime files
              checkThirdParty = false,                           -- avoid unecessary prompts?
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("pylsp", {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                maxLineLength = 140, -- Set maximum line length
              },
            },
          },
        },
      })

      -- cmake-language-server is installed via pipx (on PATH), not mason, so it
      -- isn't in ensure_installed/automatic_enable above. Enable it explicitly.
      -- NOTE: the pipx venv must pin pygls>=1.1.1,<2.0 — pygls 2.x removed the
      -- pygls.server.LanguageServer import this server relies on.
      vim.lsp.enable("cmake")
    end,
  },

  -- LuaSnip configuration
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  -- nvim-lspconfig for setting up LSP servers
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
    },
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          -- Format-on-save is handled by conform.nvim (with lsp_fallback)
          -- Removed duplicate BufWritePre hook that conflicted with conform
        end,
      })
      -- LSP keybindings are set in init.lua LspAttach autocmd
    end,
  },
  {
    "folke/neodev.nvim", -- Add this
    lazy = false,
    config = function()
      require("neodev").setup({
        library = { plugins = {}, types = true },
      })
    end,
  },
}
