return {
  "andythigpen/nvim-coverage",
  version = "*",
  config = function()
    local coverage = require("coverage")

    coverage.setup({
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
    })

    vim.keymap.set("n", "<leader>ta", function()
      coverage.load()
      coverage.summary()
    end, { desc = "Toggle Coverage / Show Summary" })
  end,
  opts = {
    auto_reload = true,
  },
}
