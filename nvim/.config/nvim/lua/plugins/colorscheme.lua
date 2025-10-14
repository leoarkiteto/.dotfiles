return {
  {
    "ellisonleao/gruvbox.nvim",
  },
  {
    "Mofiqul/dracula.nvim",
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      styles = {
        comments = { "italic" },
        strings = { "italic" },
        types = { "underline" },
      },
    },
  },
  {
    "navarasu/onedark.nvim",
    opts = {
      code_style = {
        strings = "italic",
        comments = "italic",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
