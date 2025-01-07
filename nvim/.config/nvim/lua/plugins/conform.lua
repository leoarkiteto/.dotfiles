return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
    },
  },
}
