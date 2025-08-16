return {
  "MeaderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.icons",
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
