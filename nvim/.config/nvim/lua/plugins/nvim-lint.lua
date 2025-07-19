return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      typescript = { "biomejs" },
      typescriptreact = { "biomejs" },
      vue = { "biomejs" },
      json = { "biomejs" },
      jsonc = { "biomejs" },
      markdown = { "markdownlint-cli2" },
    },
  },
}
