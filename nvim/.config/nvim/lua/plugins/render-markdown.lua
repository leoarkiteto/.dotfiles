return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons",
  },
  opts = {
    code = {
      enabled = true,
      sign = true,
    },
    heading = {
      enabled = true,
      sign = true,
      icons = { "󰲡", "󰲣", "󰲥", "󰲧", "󰲩", "󰲫" },
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
