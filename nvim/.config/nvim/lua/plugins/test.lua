return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-jest",
    "nvim-neotest/nvim-nio",
    "Issafalcon/neotest-dotnet",
    "marilari88/neotest-vitest",
    "nvim-lua/plenary.nvim",
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

    local function find_config(file, patterns)
      local project_root = get_project_root(file)
      for _, pattern in ipairs(patterns) do
        local config = project_root .. pattern
        if vim.fn.filereadable(config) == 1 then
          return config
        end
      end

      return nil
    end

    local function get_package_manager()
      local project_root = vim.fn.getcwd()
      if vim.fn.filereadable(project_root .. "/pnpm-lock.yaml") == 1 then
        return "pnpm"
      elseif vim.fn.filereadable(project_root .. "/yarn.lock") == 1 then
        return "yarn"
      else
        return "npm"
      end
    end

    local function get_jest_config(file)
      local patterns = { "jest.config.ts", "jest.config.js" }
      return find_config(file, patterns) or vim.fn.getcwd() .. "/jest/config.ts"
    end

    local function get_vitest_config(file)
      local patterns = { "vitest.config.ts", "vitest.config.js", "vite.config.ts", "vite.config.js" }
      return find_config(file, patterns) or vim.fn.getcwd() .. "/vite.config.ts"
    end

    local default_jest_args = {
      "--verbose", -- Detailed output
      "--colors", -- Colored output
      "--coverage", -- Disable coverage by default for faster runs
      "--coverageReporters=lcov", -- Disable coverage by default for faster runs
      "--no-cache", -- Disable Jest cache
      "--watchAll=false", -- Disable watch mode
      "--testLocationInResults", -- Include location info
      "--reporters=default", -- Use default reporter for better terminal output
      "--errorOnDeprecated", -- Show errors for deprecated features
    }

    local default_vitest_args = {
      "run",
      "--coverage",
      "--no-watch",
    }

    local default_dotnet_args = {
      "--verbosity",
      "detailed",
      "--logger",
      "console;verbosity=detailed",
      "--collect",
      "XPlat Code Coverage",
    }

    --==== JavaScript adapters (Jest) ====--
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
            local pkg_manager = get_package_manager()
            base_command = pkg_manager .. " jest"
          end
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
      })
    )

    --==== JavaScript adapters (Vitest) ====--
    table.insert(
      opts.adapters,
      require("neotest-vitest")({
        vitestCommand = function(file)
          local pkg_manager = get_package_manager()
          local args = table.concat(default_vitest_args, "")

          if is_nx_project() then
            local project_name = get_project_name(file)
            return string.format("nx test %s -- %s", project_name, args)
          end
          return string.format("%s exec vitest run %s", pkg_manager, args)
        end,
        vitestConfigFile = get_vitest_config,
        env = { CI = true },
        cwd = get_project_root,
      })
    )

    --==== .NET adapters ====--
    table.insert(
      opts.adapters,
      require("neotest-dotnet")({
        dap = { justMyCode = false },
        dotnet_additional_args = table.concat(default_dotnet_args, " "),
        custom_project_root = get_dotnet_project_root,
        discovery_method = "dll",
        runner = {
          name = "dotnet",
          env = {
            DOTNET_CLI_UI_LANGUAGE = "en-US",
            DOTNET_NOLOGO = "true",
          },
        },
        output = {
          enabled = true,
          open_on_run = true,
        },
      })
    )

    -- Configure common neotest options for better output
    opts.quickfix = {
      enabled = true,
      open = true,
    }
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

    local function find_coverage_report()
      local project_root = vim.fn.getcwd()
      local possible_paths = {
        "/coverage/index.html",
        "/coverage/lcov-report/index.html",
        "/coverage/html/index.html",
      }

      for _, path in ipairs(possible_paths) do
        local full_path = project_root .. path
        if vim.fn.filereadable(full_path) == 1 then
          return full_path
        end
      end

      return nil
    end

    local function find_dotnet_coverage_report()
      local project_root = vim.fn.getcwd()
      local coverage_dir = vim.fn.glob(project_root .. "/TestResults/*/coverage.cobertura.xml")

      if coverage_dir ~= "" then
        return coverage_dir
      end

      local report_path = vim.fn.glob(project_root .. "/**/coverage.xml")

      if report_path ~= "" then
        return report_path
      end

      return nil
    end

    vim.api.nvim_create_user_command("TestCoverage", function()
      local file_type = vim.bo.filetype
      if file_type == "cs" then
        local coverage_path = find_dotnet_coverage_report()
        if coverage_path then
          local has_report_gen = vim.fn.executable("reportgenerator") == 1
          if has_report_gen then
            local output_dir = vim.fn.getcwd() .. "/CoverageReport"
            local cmd = string.format(
              'reportgenerator -reports:"%s" -targetdir:"%s" -reporttypes:Html',
              coverage_path,
              output_dir
            )
            vim.fn.system(cmd)

            local index_html = output_dir .. "/index.html"
            if vim.fn.filereadable(index_html) == 1 then
              if vim.fn.has("mac") == 1 then
                vim.fn.system("open" .. index_html)
              elseif vim.fn.has("unix") then
                vim.fn.system("xdg-open" .. index_html)
              elseif vim.fn.has("win32") then
                vim.fn.system("start" .. index_html)
              end
            else
              vim.notify("Failed to generate coverage report", vim.log.levels.ERROR)
            end
          else
            vim.notify(
              'ReportGenerator not found. Install with "dotnet tool install -g dotnet-reportgenerator-globaltool"',
              vim.log.levels.WARN
            )
          end
        else
          vim.notify(".NET coverage report not found. Run tests with coverage first", vim.log.levels.WARN)
        end
      elseif
        file_type == "typescript"
        or file_type == "javascript"
        or file_type == "typescriptreact"
        or file_type == "javascriptreact"
      then
        local coverage_path = find_coverage_report()
        if coverage_path then
          if vim.fn.has("mac") == 1 then
            vim.fn.system("open " .. coverage_path)
          elseif vim.fn.has("unix") == 1 then
            vim.fn.system("xdg-open " .. coverage_path)
          elseif vim.fn.has("win32") == 1 then
            vim.fn.system("start " .. coverage_path)
          end
        else
          vim.notify("Coverage report not found. Run tests with coverage first", vim.log.levels.WARN)
          local config_path = vim.fn.getcwd() .. "/vitest.config.ts"
          if vim.fn.filereadable(config_path) == 0 then
            vim.notify(
              "Consider adding a vitest.config.ts with coverage configuration:\n\n"
                .. 'import {defineConfig} from "vitest/config"\n\n'
                .. "export default defineConfig({\n"
                .. "test: {\n"
                .. "coverage: {\n"
                .. 'provider: "v8",\n'
                .. 'reporter: ["text", "html"],\n'
                .. 'reportsDirectory: "./coverage"\n'
                .. "}\n"
                .. "}\n"
                .. "})",
              vim.log.levels.INFO
            )
          end
        end
      end
    end, {})

    vim.keymap.set("n", "<leader>tc", ":TestCoverage<CR>", { desc = "Show test coverage" })
  end,
}
