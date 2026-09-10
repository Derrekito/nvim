-- devdocs.nvim: offline reference docs (cppreference C++23, C, Lua,
-- Bash, CMake, Python) converted to real markdown. gK looks up the symbol
-- under the cursor; :Devdocs browses/searches; :DevdocsUpdate refreshes.
return {
  "Derrekito/devdocs.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
    viewer = "markdown", -- rendered markdown pages (alternative: "man")
    split = "right",     -- docs open to the right; code frame stays pinned at `width`
    pin = true,          -- hold the code frame at `width` cols; docs get the rest
  },
}
