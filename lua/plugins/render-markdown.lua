return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    completions = { lsp = { enabled = true } },

    -- Render in visual modes too (insert stays raw: it's not listed, so the
    -- whole buffer shows plain markdown there — preferred for editing).
    render_modes = { "n", "c", "t", "v", "V", "\22" },

    anti_conceal = {
      -- Never reveal the cursor line's raw text in rendered modes (normal,
      -- visual, ...); raw editing belongs to insert mode, where the whole
      -- buffer shows plain markdown anyway.
      enabled = false,
    },

    heading = {
      enabled = true,
      sign = false,
      position = "overlay",
      icons = {},
      width = "block",
      left_pad = 0,
      right_pad = 4,
      min_width = 60,
      border = false,
      backgrounds = {
        "RenderMarkdownH1Bg",
        "RenderMarkdownH2Bg",
        "RenderMarkdownH3Bg",
        "RenderMarkdownH4Bg",
        "RenderMarkdownH5Bg",
        "RenderMarkdownH6Bg",
      },
      foregrounds = {
        "RenderMarkdownH1",
        "RenderMarkdownH2",
        "RenderMarkdownH3",
        "RenderMarkdownH4",
        "RenderMarkdownH5",
        "RenderMarkdownH6",
      },
    },

    code = {
      enabled = true,
      sign = false,
      style = "full",
      position = "left",
      language_pad = 2,
      width = "block",
      left_pad = 1,
      right_pad = 2,
      border = "thin",
      highlight = "RenderMarkdownCode",
      highlight_inline = "RenderMarkdownCodeInline",
    },

    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" },
      right_pad = 1,
    },

    checkbox = {
      enabled = true,
      position = "overlay",
      unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
      checked   = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
      custom = {
        todo = { raw = "[~]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
      },
    },

    quote = {
      enabled = true,
      icon = "▍",
      repeat_linebreak = true,
      highlight = "RenderMarkdownQuote",
    },

    pipe_table = {
      enabled = true,
      style = "full",
      cell = "padded",
      alignment_indicator = "━",
      border = {
        "╭", "┬", "╮",
        "├", "┼", "┤",
        "╰", "┴", "╯",
        "│", "─",
      },
      head = "RenderMarkdownTableHead",
      row = "RenderMarkdownTableRow",
      filler = "RenderMarkdownTableFill",
    },

    callout = {
      note      = { raw = "[!NOTE]",      rendered = "󰋽 Note",      highlight = "RenderMarkdownInfo" },
      tip       = { raw = "[!TIP]",       rendered = "󰌶 Tip",       highlight = "RenderMarkdownSuccess" },
      important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
      warning   = { raw = "[!WARNING]",   rendered = "󰀪 Warning",   highlight = "RenderMarkdownWarn" },
      caution   = { raw = "[!CAUTION]",   rendered = "󰳦 Caution",   highlight = "RenderMarkdownError" },
    },

    link = {
      enabled = true,
      image = "󰥶 ",
      hyperlink = "󰌹 ",
      highlight = "RenderMarkdownLink",
    },

    dash = {
      enabled = true,
      icon = "─",
      width = "full",
      highlight = "RenderMarkdownDash",
    },
  },
  config = function(_, opts)
    local builtin_latex = require("render-markdown.handler.latex")
    opts.custom_handlers = {
      latex = {
        parse = function(ctx)
          local start_row, start_col = ctx.root:range()
          local md_node = vim.treesitter.get_node({
            bufnr = ctx.buf,
            pos = { start_row, start_col },
            lang = "markdown",
            ignore_injections = true,
          })
          while md_node do
            if md_node:type() == "fenced_code_block" then
              return {}
            end
            md_node = md_node:parent()
          end
          return builtin_latex.parse(ctx)
        end,
      },
    }
    require("render-markdown").setup(opts)

    local function apply_highlights()
      local function hl(group, def) vim.api.nvim_set_hl(0, group, def) end

      -- Rose-pine moon palette (shared source of truth)
      local p = require("rose-pine-moon").palette

      -- Heading bar backgrounds: hue-tinted darkenings of each accent
      -- color, sitting visibly above the moon `base` (#232136).
      hl("RenderMarkdownH1Bg", { bg = "#3c2d56" })  -- iris-tinted
      hl("RenderMarkdownH2Bg", { bg = "#1f4250" })  -- foam-tinted
      hl("RenderMarkdownH3Bg", { bg = "#523140" })  -- rose-tinted
      hl("RenderMarkdownH4Bg", { bg = "#523f1f" })  -- gold-tinted
      hl("RenderMarkdownH5Bg", { bg = "#1f3f50" })  -- pine-tinted
      hl("RenderMarkdownH6Bg", { bg = "#2d3a4e" })  -- foam-muted

      hl("RenderMarkdownH1", { fg = p.iris, bold = true })
      hl("RenderMarkdownH2", { fg = p.foam, bold = true })
      hl("RenderMarkdownH3", { fg = p.rose, bold = true })
      hl("RenderMarkdownH4", { fg = p.gold, bold = true })
      hl("RenderMarkdownH5", { fg = p.pine, bold = true })
      hl("RenderMarkdownH6", { fg = p.foam, bold = true })

      hl("RenderMarkdownCode",       { bg = p.surface })
      hl("RenderMarkdownCodeInline", { bg = p.overlay, fg = p.text })

      hl("RenderMarkdownChecked",   { fg = p.foam })
      hl("RenderMarkdownUnchecked", { fg = p.muted })
      hl("RenderMarkdownTodo",      { fg = p.gold })

      hl("RenderMarkdownQuote", { fg = p.iris })
      hl("RenderMarkdownLink",  { fg = p.foam, underline = true })
      hl("RenderMarkdownDash",  { fg = p.highlight_med })

      hl("RenderMarkdownTableHead", { fg = p.iris, bold = true })
      hl("RenderMarkdownTableRow",  { fg = p.text })
      hl("RenderMarkdownTableFill", { fg = p.highlight_med })

      hl("RenderMarkdownInfo",    { fg = p.foam, bold = true })
      hl("RenderMarkdownSuccess", { fg = p.pine, bold = true })
      hl("RenderMarkdownHint",    { fg = p.iris, bold = true })
      hl("RenderMarkdownWarn",    { fg = p.gold, bold = true })
      hl("RenderMarkdownError",   { fg = p.love, bold = true })
    end

    apply_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = apply_highlights,
    })
  end,
}
