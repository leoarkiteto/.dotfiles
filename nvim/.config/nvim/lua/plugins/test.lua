-- =====================================================
-- Utility functions
-- =====================================================

-- Check if current directory is an Nx project
---@return boolean
local function is_nx_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/nx.json") == 1
end

-- Check if file path indicates monorepo structure
---@param file string File path to check
---@return boolean
local function is_monorepo_path(file)
  return string.find(file, "/packages/") ~= nil or string.find(file, "/apps/") ~= nil
end

-- Get project root directory for given file
---@param file string File path to check
---@return string Project root path
local function get_project_root(file)
  if is_nx_project() or is_monorepo_path(file) then
    local match = string.match(file, "(.-/[^/]+/[^/]+)/")
    return match or vim.fn.getcwd()
  end
  return vim.fn.getcwd()
end

-- Extract project name from file path
---@param file string File path to check
---@return string Project name
local function get_project_name(file)
  local project_root = get_project_root(file)
  local match = string.match(project_root, "/([^/]+)/?$")
  return match or ""
end

-- Fiind configuration file using patterns
---@param file string File path to determine project root
---@param patterns table List of config file patterns to search
---@return string|nil Path to config file if found
local function find_config(file, patterns)
  local project_root = get_project_root(file)
  for _, pattern in ipairs(patterns) do
    local config = project_root .. "/" .. pattern
    if vim.fn.filereadable(config) == 1 then
      return config
    end
  end
  return nil
end

-- Detect package manager based on lock files
---@return string Package manager name
local function get_package_manager()
  local project_root = vim.fn.getcwd()
  local lock_files = {
    { file = "pnpm.lock.yaml", manager = "pnpm" },
    { file = "yarn.lock", manager = "yarn" },
  }

  for _, lock in ipairs(lock_files) do
    if vim.fn.filereadable(project_root .. "/" .. lock.file) == 1 then
      return lock.manager
    end
  end
  return "npm"
end

-- =====================================================
-- Test Framework configuration Helpers
-- =====================================================

--- Get Jest configuration file
---@param file string File path
---@return string|nil Jest config path
local function get_jest_config(file)
  local patterns = { "jest.config.ts", "jest.config.js", "jest.config.json" }
  return find_config(file, patterns)
end

--- Get Vitest configuration file
---@param file string File path
---@return string|nil Jest config path
local function get_vitest_config(file)
  local patterns = { "vitest.config.ts", "vitest.config.js", "vite.config.ts", "vite.config.js" }
  return find_config(file, patterns)
end

--- Build Jest command with proper arguments
---@param file string File path
---@return string Jest command
local function build_jest_command(file)
  local default_jest_args = {
    "--verbose",
    "--colors",
    "--no-cache",
    "--watchAll=false",
    "--testLocationInResults",
    "--reporters=default",
    "--errorOnDeprecated",
  }

  local base_command
  if is_nx_project() then
    local project_name = get_project_name(file)
    base_command = string.format("nx test %s", project_name)
  else
    local pkg_manager = get_package_manager()
    base_command = pkg_manager .. " test"
  end

  local args = table.concat(default_jest_args, " ")
  return base_command .. " -- " .. args
end

--- Build Vitest command with proper arguments
---@param file string File path
---@return string Vitest command
local function build_vitest_command(file)
  local default_vitest_args = { "run", "--no-watch" }
  local pkg_manager = get_package_manager()
  local args = table.concat(default_vitest_args, " ")

  if is_nx_project() then
    local project_name = get_project_name(file)
    return string.format("nx test %s -- %s", project_name, args)
  end
  return string.format("%s exec vitest %s", pkg_manager, args)
end

-- =====================================================
-- Coverage Report Functions
-- =====================================================

--- Find JavaScript/TypeScript coverage report
---@return string|nil Path to coverage report
local function find_js_coverage_report()
  local project_root = vim.fn.getcwd()
  local possible_paths = {
    "/coverage/index.html",
    "/coverage/lcov-report/index.html",
    "/coverage/html/index.html",
    "/coverage/html-report/index.html",
  }

  for _, path in ipairs(possible_paths) do
    local full_path = project_root .. path
    if vim.fn.filereadable(full_path) == 1 then
      return full_path
    end
  end
  return nil
end

--- Find .NET coverage report
---@return string|nil Path to coverage report
local function find_dotnet_coverage_report()
  local project_root = vim.fn.getcwd()

  -- Look for Cobertura format first
  local cobertura_pattern = project_root .. "/TestResults/*/coverage.cobertura.xml"
  local cobertura_files = vim.fn.glob(cobertura_pattern, false, true)
  if #cobertura_files > 0 then
    return cobertura_files[1]
  end

  -- Fallback to general coverage.xml
  local coverage_pattern = project_root .. "/**/coverage.xml"
  local coverage_files = vim.fn.glob(coverage_pattern, false, true)
  if #coverage_files > 0 then
    return coverage_files[1]
  end

  return nil
end

--- Open file using system default application
---@param file_path string Path to file
---@return boolean Success status
local function open_with_system(file_path)
  local commands = {
    mac = "open '" .. file_path .. "'",
    unix = "xdg-open '" .. file_path .. "'",
    win32 = 'start "" "' .. file_path .. '"',
  }

  local cmd
  if vim.fn.has("mac") == 1 then
    cmd = commands.mac
  elseif vim.fn.has("unix") == 1 then
    cmd = commands.unix
  elseif vim.fn.has("win32") == 1 then
    cmd = commands.win32
  else
    vim.notify("Unsupported platform for opening files", vim.log.levels.ERROR)
    return false
  end

  vim.fn.system(cmd)
  return vim.v.shell_error == 0
end

---- Handle .NET coverage report generation and opening
---@param coverage_path string Path to coverage XML file
local function handle_dotnet_coverage(coverage_path)
  if vim.fn.executable("reportgenerator") ~= 1 then
    vim.notify(
      'ReportGenerator not found. Install with "dotnet tool install -g dotnet-reportgenerator-globaltool"',
      vim.log.levels.WARN
    )
    return
  end

  local output_dir = vim.fn.getcwd() .. "/CoverageReport"
  vim.fn.mkdir(output_dir, "p")

  local cmd = string.format('reportgenerator -report:"%s" -targetdir:"%s" -reporttypes:Html', coverage_path, output_dir)
  vim.notify("Generating coverage report...", vim.log.levels.INFO)
  local result = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    local index_html = output_dir .. "/index.html"
    if vim.fn.filereadable(index_html) == 1 then
      if open_with_system(index_html) then
        vim.notify("Coverage report opened successfully", vim.log.levels.INFO)
      else
        vim.notify("Failed to open coverage report", vim.log.levels.ERROR)
      end
    else
      vim.notify("Coverage report file not found", vim.log.levels.ERROR)
    end
  else
    vim.notify("Failed to generate coverage report: " .. result, vim.log.levels.ERROR)
  end
end

--- Show coverage instructions for JavaScript/TypeScript projects
local function show_js_coverage_instructions()
  vim.notify("Coverage report not found. Run tests with coverage first", vim.log.levels.WARN)

  local project_root = vim.fn.getcwd()
  local vitest_config = project_root .. "/vitest.config.ts"
  local jest_config = project_root .. "/jest.config.ts"

  if vim.fn.filereadable(vitest_config) == 0 and vim.fn.filereadable(jest_config) == 0 then
    vim.notify(
      "Consider adding test configuration with coverage enabled.\n"
        .. "For Vitest: Add coverage config to vitest.config.ts\n"
        .. "For Jest: Add coverage config to jest.config.js",
      vim.log.levels.INFO
    )
  end
end

-- =====================================================
-- Test Coverage Command
-- =====================================================

--- Handle test coverage based on current file type
local function handle_test_coverage()
  local file_type = vim.bo.filetype

  if file_type == "cs" then
    local coverage_path = find_dotnet_coverage_report()
    if coverage_path then
      handle_dotnet_coverage(coverage_path)
    else
      vim.notify(".NET coverage report not found. Run tests with coverage first", vim.log.levels.WARN)
      vim.notify('To generate coverage: dotnet test --collect:"Xplat Code Coverage"', vim.log.levels.INFO)
    end
  elseif vim.tbl_contains({ "typescript", "javascript", "typescriptreact", "javascriptreact" }, file_type) then
    local coverage_path = find_js_coverage_report()
    if coverage_path then
      if open_with_system(coverage_path) then
        vim.notify("Coverage report opened successfully", vim.log.levels.INFO)
      else
        vim.notify("Failed to open coverage report", vim.log.levels.ERROR)
      end
    else
      show_js_coverage_instructions()
    end
  else
    vim.notify("Test coverage not supported for filetype: " .. file_type, vim.log.levels.WARN)
  end
end

-- =====================================================
-- Main Plugin configuration
-- =====================================================

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
    "Issafalcon/neotest-dotnet",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}

    -- Jest adapter configuration
    table.insert(
      opts.adapters,
      require("neotest-jest")({
        jest_test_discovery = false,
        jestCommand = build_jest_command,
        jestConfigFile = get_jest_config,
        env = { CI = true },
        cwd = get_project_root,
      })
    )

    -- Vitest adapter configuration
    table.insert(
      opts.adapters,
      require("neotest-vitest")({
        vitestCommand = build_vitest_command,
        vitestConfigFile = get_vitest_config,
        env = { CI = true },
        cwd = get_project_root,
      })
    )

    -- .NET adapter configuration
    table.insert(
      opts.adapters,
      require("neotest-dotnet")({
        dap = {
          args = { justMyCode = false },
          adapter_name = "netcoredbg",
        },
        dotnet_additional_args = { "--verbosity", "detailed" },
        discovery_root = "solution",
      })
    )

    -- Neotest general configuration
    local neotest_config = {
      discovery = {
        enabled = true,
        concurrent = 1,
      },
      running = {
        concurrent = true,
      },
      quickfix = {
        enabled = true,
        open = false,
      },
      output = {
        enabled = true,
        open_on_run = "short",
      },
      output_panel = {
        enabled = true,
        open = "botright split | resize 15",
      },
    }

    -- Apply configuration
    for key, value in pairs(neotest_config) do
      opts[key] = value
    end

    -- Setup coverage command
    vim.api.nvim_create_user_command("TestCoverage", handle_test_coverage, {
      desc = "Open test coverage report",
    })
  end,
}
