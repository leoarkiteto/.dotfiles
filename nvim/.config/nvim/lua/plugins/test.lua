return {
  "nvim-neotest/neotest",
  dependencies = { "nvim-neotest/neotest-jest", "marilari88/neotest-vitest", "nvim-neotest/neotest-go" },
  opts = function(_, opts)
    -- Go adapters
    table.insert(
      opts.adapters,
      require("neotest-go")({
        experimental = {
          test_table = true,
        },
        args = { "-count=1", "-timeout=60s" },
        recursive_run = true,
      })
    )

    -- JavaScript adapters (jest,vitest)
    table.insert(
      opts.adapters,
      require("neotest-jest")({
        jest_test_discovery = false,
        discovery = {
          enable = false,
        },
        -- jestCommand = "pnpm test --",
        jestCommand = "yarn test --",
        jestConfigFile = function(file)
          if string.find(file, "/packages/") then
            return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
          end

          return vim.fn.getcwd() .. "/jest.config.ts"
        end,
        env = { CI = true },
        cwd = function(file)
          if string.find(file, "/packages/") then
            return string.match(file, "(.-/[^/]+/)src")
          end
          return vim.fn.getcwd()
        end,
      })
    )
    table.insert(opts.adapters, require("neotest-vitest"))
  end,
}
