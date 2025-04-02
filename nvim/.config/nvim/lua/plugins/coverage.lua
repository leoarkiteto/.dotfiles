return {
  "andythigpen/nvim-coverage",
  version = "*",
  keys = {
    {
      "<leader>ta",
      function()
        local coverage = require("coverage")
        coverage.load()
        coverage.summary()
      end,
      desc = "Toggle Coverage/Show Summary",
    },
  },
  opts = {
    auto_reload = true,
    lang = {
      go = {
        coverage_file = function()
          local current_file = vim.fn.expand("%:p")
          local dir = vim.fn.fnamemodify(current_file, ":h")
          return dir .. "/coverage.out"
        end,
      },
      typescript = {
        coverage_file = function()
          local root_dir = vim.fn.getcwd()
          return root_dir .. "/coverage/lcov.info"
        end,
      },
    },
  },
}
