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

--- Show coverage instructions for JavaScript/TypeScript projects
local function show_js_coverage_instructions()
  vim.notify("Coverage report not found. Run tests with coverage first", vim.log.levels.WARN)

  local project_root = vim.fn.getcwd()
  local vitest_config = vim.fs.joinpath(project_root, "vitest.config.ts")
  local json_config = vim.fs.joinpath(project_root, "jest.config.js")

  if vim.fn.filereadable(vitest_config) == 0 and vim.fn.filereadable(json_config) == 0 then
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

  if vim.tbl_contains({ "typescript", "javascript", "typescriptreact", "javascriptreact" }, file_type) then
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
