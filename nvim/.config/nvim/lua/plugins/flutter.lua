return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    widget_guides = {
      enabled = true,
    },
    lsp = {
      color = {
        enabled = true,
      },
    },
    outline = {
      open_cmd = "30vnew",
      auto_open = true,
    },
    closing_tags = {
      prefix = ">",
    },
  },
}
