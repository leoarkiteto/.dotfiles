return {
  "nvim-mini/mini.diff",
  event = "VeryLazy",
  opts = {
    -- Use git as the source for diff information
    source = require("mini.diff").gen_source.git(),
    -- Configure the view style
    view = {
      style = "sign",
      signs = { add = "▒", change = "▒", delete = "▒" },
    },
    -- Configure highlighting
    highlight = {
      add = "DiffAdd",
      change = "DiffChange",
      delete = "DiffDelete",
    },
  },
  keys = {
    {
      "<leader>go",
      function()
        require("mini.diff").toggle_overlay(0)
      end,
      desc = "Toggle mini.diff overlay",
    },
    {
      "<leader>gO",
      function()
        require("mini.diff").toggle_overlay(0, { source = require("mini.diff").gen_source.none() })
      end,
      desc = "Disable mini.diff overlay",
    },
  },
}
