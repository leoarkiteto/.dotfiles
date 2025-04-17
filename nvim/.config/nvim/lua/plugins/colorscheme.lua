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
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
      styles = {
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
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
