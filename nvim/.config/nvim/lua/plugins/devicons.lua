return {
  "nvim-tree/nvim-web-devicons",
  opts = {
    override_by_extension = {
      ["json"] = {
        icon = "󰘦",
        color = "#f4db20",
        name = "JSON",
      },
    },
    override_by_filename = {
      [".prettierrc"] = {
        icon = "",
        color = "#f8bb45",
        name = "Prettier",
      },
      [".prettierrc.json"] = {
        icon = "",
        color = "#f8bb45",
        name = "Prettier",
      },
      ["eslint.config.js"] = {
        icon = "󰱺",
        color = "#7e7eee",
        name = "ESLint",
      },
      [".eslintrc"] = {
        icon = "󰱺",
        color = "#7e7eee",
        name = "ESLint",
      },
      ["eslintrc.json"] = {
        icon = "󰱺",
        color = "#7e7eee",
        name = "ESLint",
      },
    },
    override_by_operating_system = {
      ["apple"] = {
        icon = "",
        color = "#a2aaad",
        cterm_color = "248",
        name = "Apple",
      },
    },
  },
}
