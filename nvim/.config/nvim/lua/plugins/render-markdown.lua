return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons",
  },
  opts = {
    code = {
      sign = true,
    },
    heading = {
      sign = true,
      icons = { "󰲡", "󰲣", "󰲥", "󰲧", "󰲩", "󰲫" },
    },
    checkbox = {
      enable = true,
    },
  },
}
