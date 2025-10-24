return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons",
  },
  opts = {
    file_types = { "markdown", "codecompanion" },
    completions = {
      blink = { enabled = true },
    },
    code = {
      enabled = true,
      sign = true,
      language = true,
    },
    heading = {
      enabled = true,
      position = "left",
      right_pad = 10,
      sign = true,
      icons = { "󰇊 ", "󰇋 ", "󰇌 ", "󰇍 ", "󰇎 ", "󰇏 " },
    },
    checkbox = {
      enabled = true,
      bullet = true,
      unchecked = {
        icon = "󰄱 ",
      },
      checked = {
        icon = "󰱒 ",
      },
    },
  },
}
