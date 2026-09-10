-- diagnostic-picker.nvim plugin configuration
return {
  "Derrekito/diagnostic-picker.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("diagnostic-picker").setup({
      debug = false,
      debug_file = "/tmp/diagnostic-picker-debug.log",
      severities = {
        ERROR = true,
        WARN  = true,
        INFO  = true,
        HINT  = true,
      },
    })
  end,
  keys = {
    {
      "<leader>dg",
      function()
        require("diagnostic-picker").show()
      end,
      desc = "Diagnostic settings",
    },
  },
}
