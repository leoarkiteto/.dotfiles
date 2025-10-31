-- =====================================================
-- Utility functions
-- =====================================================

-- Check if current directory is an Nx project
---@return boolean
local function is_nx_project()
  return vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), "nx.json")) == 1
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
    -- Extract path up to packages/[project_name] or apps/[project_name]
    local match = string.match(file, "(.-/[^/]+/[^/]+)")
    if match and vim.fn.isdirectory(match) == 1 then
      return match
    end
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
    local config = vim.fs.joinpath(project_root, pattern)
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
    { file = "pnpm-lock.yaml", manager = "pnpm" },
    { file = "yarn.lock", manager = "yarn" },
    { file = "package-lock.json", manager = "npm" },
  }

  for _, lock in ipairs(lock_files) do
    if vim.fn.filereadable(vim.fs.joinpath(project_root, lock.file)) == 1 then
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
  local default_vitest_args = { "run" }
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
    "coverage/index.html",
    "coverage/lcov-report/index.html",
    "coverage/html/index.html",
    "coverage/html-report/index.html",
  }

  for _, path in ipairs(possible_paths) do
    local full_path = vim.fs.joinpath(project_root, path)
    if vim.fn.filereadable(full_path) == 1 then
      return full_path
    end
  end
  return nil
end

--- Get the current project name from the current file path
---@return string|nil Project name
local function get_current_project_name()
  local current_file = vim.fn.expand("%:p")
  if not current_file or current_file == "" then
    return nil
  end

  local project_root = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(current_file, ":.")

  -- Extract project name from path like "CustomerBatchImporter/SomeFile.cs"
  local project_match = string.match(relative_path, "^([^/]+)/")
  if project_match then
    return project_match
  end

  return nil
end

--- Find .NET coverage report
---@return string|nil Path to coverage report
local function find_dotnet_coverage_report()
  local project_root = vim.fn.getcwd()
  local current_project = get_current_project_name()

  -- First, try to find coverage for the current project
  if current_project then
    local current_project_pattern =
      vim.fs.joinpath(project_root, current_project, "TestResults", "*", "coverage.cobertura.xml")
    local current_project_files = vim.fn.glob(current_project_pattern, false, true)

    if #current_project_files > 0 then
      return current_project_files[1]
    end
  end

  -- Look for Cobertura format in solution root first
  local cobertura_pattern = vim.fs.joinpath(project_root, "TestResults", "*", "coverage.cobertura.xml")
  local cobertura_files = vim.fn.glob(cobertura_pattern, false, true)

  if #cobertura_files > 0 then
    return cobertura_files[1]
  end

  -- Look for Cobertura format in project subdirectories (most common)
  local project_cobertura_pattern = vim.fs.joinpath(project_root, "*", "TestResults", "*", "coverage.cobertura.xml")
  local project_cobertura_files = vim.fn.glob(project_cobertura_pattern, false, true)

  if #project_cobertura_files > 0 then
    return project_cobertura_files[1]
  end

  -- Look for OpenCover format
  local opencover_pattern = vim.fs.joinpath(project_root, "**", "*OpenCover*.xml")
  local opencover_files = vim.fn.glob(opencover_pattern, false, true)

  -- Filter out directories and only return actual files
  local valid_opencover_files = {}
  for _, file in ipairs(opencover_files) do
    if vim.fn.filereadable(file) then
      table.insert(valid_opencover_files, file)
    end
  end

  if #valid_opencover_files > 0 then
    return valid_opencover_files[1]
  end

  -- Look for any coverage XML files anywhere in the solution (more specific)
  local any_coverage_pattern = vim.fs.joinpath(project_root, "**", "*coverage*.xml")
  local any_coverage_files = vim.fn.glob(any_coverage_pattern, false, true)

  -- Filter out directories and only return actual files
  local valid_files = {}
  for _, file in ipairs(any_coverage_files) do
    if vim.fn.filereadable(file) then
      table.insert(valid_files, file)
    end
  end

  if #valid_files > 0 then
    return valid_files[1]
  end

  -- Debug: Log what we search for
  vim.notify("No coverage files found. Searched patterns:", vim.log.levels.DEBUG)
  if current_project then
    vim.notify("  - Current project: " .. current_project, vim.log.levels.DEBUG)
  end

  vim.notify("  - " .. cobertura_pattern, vim.log.levels.DEBUG)
  vim.notify("  - " .. project_cobertura_pattern, vim.log.levels.DEBUG)
  vim.notify("  - " .. opencover_pattern, vim.log.levels.DEBUG)
  vim.notify("  - " .. any_coverage_pattern, vim.log.levels.DEBUG)
  vim.notify(
    "  - Found " .. #any_coverage_files .. " potential files, " .. #valid_files .. " valid files",
    vim.log.levels.DEBUG
  )

  return nil
end

--- Open file using system default application
---@param file_path string Path to file
---@return boolean Success status
local function open_with_system(file_path)
  local escaped_path = vim.fn.shellescape(file_path)
  local commands = {
    mac = "open " .. escaped_path,
    unix = "xdg-open " .. escaped_path,
    win32 = 'start "" ' .. escaped_path,
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

  -- Validate that coverage_path is a file and exists
  if not coverage_path or vim.fn.filereadable(coverage_path) ~= 1 then
    vim.notify("Coverage file not found: " .. (coverage_path or "nil"), vim.log.levels.ERROR)
    return
  end

  -- Determine the project directory from the coverage file path
  local project_dir = vim.fn.fnamemodify(coverage_path, ":h:h:h") -- Go up 3 levels: file -> TestResults -> projects
  local project_name = vim.fn.fnamemodify(project_dir, ":t") -- Get the project name
  local output_dir = vim.fs.joinpath(project_dir, "CoverageReport")

  -- Create the coverage directory in the project folder
  vim.fn.mkdir(output_dir, "p")

  local cmd = string.format(
    "reportgenerator -reports:%s -targetdir:%s -reporttypes:Html",
    vim.fn.shellescape(coverage_path),
    vim.fn.shellescape(output_dir)
  )

  vim.notify("Generating coverage report for project: " .. project_name, vim.log.levels.INFO)
  local resutl = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    local index_html = vim.fs.joinpath(output_dir, "index.html")
    if vim.fn.filereadable(index_html) == 1 then
      if open_with_system(index_html) then
        vim.notify("Coverage report opened successfully for " .. project_name, vim.log.levels.INFO)
      else
        vim.notify("Failed to open coverage report", vim.log.levels.ERROR)
      end
    else
      vim.notify("Coverage report file not found", vim.log.levels.ERROR)
    end
  else
    vim.notify("Failed to generate coverage report: " .. resutl, vim.log.levels.ERROR)
  end
end

--- Show coverage instructions for JavaScript/TypeScript projects
local function show_js_coverage_instructions()
  vim.notify("Coverage report not found. Run tests with coverage first", vim.log.levels.WARN)

  local project_root = vim.fn.getcwd()
  local vitest_config = vim.fs.joinpath(project_root, "vitest.config.ts")
  local jest_config = vim.fs.joinpath(project_root, "jest.config.js")

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
    local current_project = get_current_project_name()
    if current_project then
      vim.notify("Current project: " .. current_project, vim.log.levels.INFO)
    end

    local coverage_path = find_dotnet_coverage_report()
    if coverage_path then
      local project_name = vim.fn.fnamemodify(vim.fn.fnamemodify(coverage_path, ":h:h:h"), ":t")
      vim.notify("Found coverage file for project '" .. project_name .. "': " .. coverage_path, vim.log.levels.INFO)
      handle_dotnet_coverage(coverage_path)
    else
      vim.notify(".NET coverage report not found. Run tests with coverage first.", vim.log.levels.WARN)
      if current_project then
        vim.notify(
          "To generate coverage for current project: dotnet test "
            .. current_project
            .. ' --collect:"XPlat Code Coverage"',
          vim.log.levels.INFO
        )
      else
        vim.notify('To generate coverage: dotnet test --collect:"XPlat Code Coverage"', vim.log.levels.INFO)
      end
      vim.notify(
        "Make sure you have the coverlet.collector NuGet package installed in your test project.",
        vim.log.levels.INFO
      )
      vim.notify("Coverage reports will be generated in each project directory", vim.log.levels.INFO)
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
-- Neotest Fast Event Fix
-- =====================================================

-- Patch vim.api.nvim_create_user_autocmd to handle event context errors
local function patch_autocmd_for_fast_events()
  -- Store the original function
  local original_create_autocmd = vim.api.nvim_create_autocmd

  -- Create a wrapped version that handles fast event errors
  vim.api.nvim_create_autocmd = function(event, opts)
    local success, result = pcall(original_create_autocmd, event, opts)

    if not success and result:match("e5560.*fast event context") then
      -- If we get the fast event error, schedule it for later
      vim.schedule(function()
        pcall(original_create_autocmd, event, opts)
      end)
      -- Return a dummy autocmd ID to prevent further errors
      return -1
    elseif success then
      return result
    else
      -- Re-throw other errors
      error(result)
    end
  end
end

-- =====================================================
-- Main Plugin configuration
-- =====================================================

return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
  },
  -- LazyVim: Define commands for lazy loading
  cmd = { "Neotest" },
  -- LazyVim: Define keymaps in plugin spec for better integration
  keys = {
    { "<leader>tc", "<cmd>TestCoverage<cr>", desc = "Show test coverage" },
  },
  init = function()
    -- Apply the patch before neotest loads
    patch_autocmd_for_fast_events()
  end,
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

    -- Setup coverage commad with scheduled execution to avoid fast events
    vim.schedule(function()
      vim.api.nvim_create_user_command("TestCoverage", function()
        vim.schedule(function()
          handle_test_coverage()
        end)
      end, { desc = "Open test coverage report" })
    end)

    return opts
  end,
}
