return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/cheatsheet",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("cheatsheet").setup()
    end,
  },
}
