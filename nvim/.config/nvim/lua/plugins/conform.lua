return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      cs = { "csharpier" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
    },
    formatters = {
      csharpier = {
        command = "csharpier",
        args = { "format", "--write-stdout" },
        stdin = true,
      },
    },
  },
}
