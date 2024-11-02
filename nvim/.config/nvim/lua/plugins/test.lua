return {
  "nvim-neotest/neotest",
  dependencies = { "haydenmeade/neotest-jest", "marilari88/neotest-vitest", "nvim-neotest/neotest-go" },
  opts = function(_, opts)
    -- Go adapters
    table.insert(
      opts.adapters,
      require("neotest-go")({
        experimental = {
          test_table = true,
        },
        args = { "-count=1", "-timeout=60s" },
      })
    )

    -- JavaScript adapters (jest,vitest)
    table.insert(
      opts.adapters,
      require("neotest-jest")({
        jestCommand = "pnpm test --",
        jestConfigFile = "custom.jest.config.ts",
        env = { CI = true },
        cwd = function()
          return vim.fn.getcwd()
        end,
      })
    )
    table.insert(opts.adapters, require("neotest-vitest"))
  end,
}
