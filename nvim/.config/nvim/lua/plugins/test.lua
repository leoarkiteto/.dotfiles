return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
    "fredrikaverpil/neotest-golang",
  },
  opts = function(_, opts)
    local function is_nx_project()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/nx.json") == 1
    end

    local function is_monorepo_path(file)
      return string.find(file, "/packages/") or string.find(file, "/apps/")
    end

    local function get_project_root(file)
      if is_nx_project() then
        return string.match(file, "(.-/[^/]+/[^/]+/)src") or vim.fn.getcwd()
      elseif is_monorepo_path(file) then
        return string.match(file, "(.-/[^/]+/[^/]+/)src") or vim.fn.getcwd()
      end
      return vim.fn.getcwd()
    end

    local function get_project_name(file)
      local project_root = get_project_root(file)
      return string.match(project_root, "/([^/]+)/src") or ""
    end

    local function get_jest_config(file)
      local project_root = get_project_root(file)
      if is_nx_project() then
        local project_config = project_root .. "jest.config.ts"
        if vim.fn.filereadable(project_config) == 1 then
          return project_config
        end
        return vim.fn.getcwd() .. "/jest.config.ts"
      end

      if is_monorepo_path(file) then
        local project_config = project_root .. "jest.config.ts"
        if vim.fn.filereadable(project_config) == 1 then
          return project_config
        end
      end
      return vim.fn.getcwd() .. "/jest.config.ts"
    end

    -- Default test arguments for better output
    local default_jest_args = {
      "--verbose", -- Detailed output
      "--colors", -- Colored output
      "--coverage=false", -- Disable coverage by default for faster runs
      "--no-cache", -- Disable Jest cache
      "--watchAll=false", -- Disable watch mode
      "--testLocationInResults", -- Include location info
      "--reporters=default", -- Use default reporter for better terminal output
      "--errorOnDeprecated", -- Show errors for deprecated features
    }

    -- Go adapters
    table.insert(
      opts.adapters,
      require("neotest-golang")({
        go_test_args = {
          "-timeout=60s",
          "-coverprofile=coverage.out",
          "-coverpkg=./...",
        },
        experimental = {
          test_table = true,
        },
        filter_dir = function(name, rel_path, root)
          return name ~= "vendor"
        end,
      })
    )
    vim.api.nvim_create_user_command("TestCoverage", function()
      vim.cmd("!go tool cover -html=coverage.out")
    end, {})

    -- Configurar atalhos de teclado específicos para testes golang
    vim.keymap.set("n", "<leader>tc", ":TestCoverage<CR>", { desc = "Show test coverage" })

    -- JavaScript adapters (jest,vitest)
    table.insert(
      opts.adapters,
      require("neotest-jest")({
        jest_test_discovery = false,
        discovery = {
          enabled = false,
        },
        jestCommand = function(file)
          local base_command
          if is_nx_project() then
            local project_name = get_project_name(file)
            base_command = string.format("nx test %s", project_name)
          else
            base_command = "pnpm test"
          end

          -- Add default arguments
          local args = table.concat(default_jest_args, " ")
          return base_command .. " -- " .. args
        end,
        jestConfigFile = get_jest_config,
        env = { CI = true },
        cwd = get_project_root,
        -- Customize the test results window
        results_window = {
          enabled = true,
          height = 15, -- Height of the results window
          width = 80, -- Width of the results window
        },
        -- Configure jest output strategies
        strategies = {
          integrated = {
            height = 40, -- Height of the integrated terminal
          },
        },
        -- Additional options for better output
        args = {
          "--bail", -- Stop running tests after first failure
          "--runInBand", -- Run tests sequentially
        },
      })
    )

    -- Configure common neotest options for better output
    opts.output = {
      enabled = true,
      open_on_run = true, -- Open output window automatically
    }

    opts.output_panel = {
      enabled = true,
      open = "botright split | resize 15", -- Open panel at bottom with height 15
    }

    opts.summary = {
      enabled = true,
      expand_errors = true, -- Expand error details automatically
      follow = true, -- Follow test output
      mappings = {
        expand = { "o", "<CR>" },
        expand_all = "O",
        output = "o",
      },
    }

    opts.icons = {
      -- You can customize these icons if you want
      passed = "󰄬",
      running = "󱕷",
      failed = "󰅖",
      skipped = "󰒲",
      unknown = "󰋖",
    }

    -- Add Vitest adapter
    table.insert(opts.adapters, require("neotest-vitest"))
  end,
}
