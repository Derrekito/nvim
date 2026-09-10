-- Diagnostics display + global user autocmds.
-- Required from init.lua AFTER lazy.nvim has loaded plugins, so these win
-- over any plugin that configures vim.diagnostic itself.

local sev = vim.diagnostic.severity
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [sev.ERROR] = "✘",
      [sev.WARN] = "⚠",
      [sev.HINT] = "💡",
      [sev.INFO] = "ℹ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local augroup = vim.api.nvim_create_augroup
local UserAutoCommands = augroup('UserAutoCommands', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = UserAutoCommands,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = UserAutoCommands,
    callback = function(e)
        local opts = { buffer = e.buf }
        -- LSP keybindings (buffer-local, only when LSP is attached)
        vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- Wider, wrapping, bordered hover/signature floats so long declarations
        -- aren't cut off. open_floating_preview IGNORES min_width (verified on
        -- 0.12), so a fixed `width` is the only way to guarantee a comfortable
        -- floor; long content then wraps, short content just has slack. 90 cols
        -- fits most C++ signatures on one or two lines.
        local float = { border = "rounded", width = 90, wrap = true }
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover(float) end, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help(float) end, opts)
        vim.keymap.set("n", "<leader>k", function() vim.lsp.buf.signature_help(float) end, opts)
        -- Browse symbols: current file (ds) vs. whole project (dS).
        vim.keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", opts)
        vim.keymap.set("n", "<leader>dS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", opts)
    end
})
--vim.api.nvim_set_option('wildmode', 'list:longest,full')
--vim.o.wildmode = 'list:longest'
