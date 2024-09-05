return {
  { "ellisonleao/gruvbox.nvim" },
  {
    "maxmx03/fluoromachine.nvim",
    opts = {
      theme = "retrowave",
      overrides = {
        ["@type"] = { underline = true },
        ["@comment"] = { italic = true },
        ["@function"] = { bold = true },
        ["@parameter"] = { italic = true },
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },
  { "navarasu/onedark.nvim", opts = {
    code_style = {
      strings = "italic",
    },
  } },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
