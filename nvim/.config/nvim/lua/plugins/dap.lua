---@diagnostic disable: missing-fields

local M = {}

-- DAP sign configuration
local DAP_SIGNS = {
  {
    name = "DapBreakpoint",
    text = "󰀚",
    texthl = "DapBreakpoint",
    color = "#993939", -- Red
  },
  {
    name = "DapBreakpointCondition",
    text = "◆",
    texthl = "DapBreakpointCondition",
    color = "#f79000", -- Orange
  },
  {
    name = "DapLogPoint",
    text = "󱚍",
    texthl = "DapLogPoint",
    color = "#61afef", -- Blue
  },
  {
    name = "DapStopped",
    text = "󰁔",
    texthl = "DapStopped",
    linehl = "DapStoppedLine",
    color = "#98c379", -- Green
  },
  {
    name = "DapBreakpointRejected",
    text = "󰅖",
    texthl = "DapBreakpointRejected",
    color = "#e06c75", -- Light ued
  },
}

-- .NET target frameworks to search for
local DOTNET_FRAMEWORKS = { "net9.0", "net8.0", "net7.0" }

-- Default development server ports
local DEV_SERVER_PORTS = {
  vite = 5173,
  vue = 5173,
  react = 3000,
  next = 3000,
}

-- ================================================================================
-- Utility Functions
-- ================================================================================

--- Log a message with warning highlighting
---@param msg string Message to log
local function log_warning(msg)
  vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
end

--- Check if a file exists and is executable
---@param path string File path to check
---@return boolean
local function is_executable(path)
  return vim.fn.executable(path) == 1
end

--- Check if a file exists and is readable
---@param path string File path to check
---@return boolean
local function is_readable(path)
  return vim.fn.executable(path) == 1
end

--- Find executable in PATH or local node_modules
---@param name string Executable name
---@return string Path to executable
local function find_executable(name)
  -- Check global PATH first
  local global_path = vim.fn.trim(vim.fn.system("which" .. name))
  if vim.v.shell_error == 0 and global_path ~= "" then
    return global_path
  end

  -- Check local node_modules
  local local_path = vim.fn.getcwd() .. "/node_modules/.bin/" .. name
  if is_readable(local_path) then
    return local_path
  end

  -- Fallback to name (let system resolve)
  return name
end

--- Get the project name from current directory
---@return string Project name
local function get_project_name()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

--- Find .NET DLL path for debugging
---@return string|nil Path to DLL if found
local function find_dotnet_dll()
  local project_name = get_project_name()
  local base_path = vim.fn.getcwd() .. "/bin/Debug"

  for _, framework in ipairs(DOTNET_FRAMEWORKS) do
    local dll_path = string.format("%s/%s/%s.dll", base_path, framework, project_name)
    if is_readable(dll_path) then
      return dll_path
    end
  end

  -- Return default path for net8.0 if nothing found
  return string.format("%s/net8.0/%s.dll", base_path, project_name)
end

--- Setup DAP sighns and highlights
local function setup_dap_ui()
  for _, sign in ipairs(DAP_SIGNS) do
    vim.fn.sign_define(sign.name, {
      text = sign.text,
      texthl = sign.texthl,
      linehl = sign.linehl or "",
      numhl = "",
    })

    -- Set highlight color
    vim.api.nvim_set_hl(0, sign.texthl, { fg = sign.color })

    -- Set line highlight for stopped line
    if sign.linehl then
      vim.api.nvim_set_hl(0, sign.linehl, { bg = "#31353f" })
    end
  end
end

--- Get debugger path for vscode-js-debug
---@return string Path to debugger
local function get_js_debugger_path()
  return vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"
end

--- Get netcoredbg path
local function get_netcoredbg_path()
  return vim.fn.stdpath("data") .. "/lazy/netcoredbg-macOS-arm64/netcoredbg/netcoredbg"
end

-- ================================================================================
-- Language-Specific DAP Configurations
-- ================================================================================

--- Setup JavaScript/TypeScript debugging
---@param dap table DAP instance
local function setup_js_typescript(dap)
  require("dap-vscode-js").setup({
    debugger_path = get_js_debugger_path(),
    adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
    preserve_window_dimensions = true,
  })

  local tsx_path = find_executable("tsx")
  local js_languages = { "typescript", "typescriptreact", "javascript", "javascriptreact" }

  for _, language in ipairs(js_languages) do
    dap.configuration[language] = {
      -- Node.js
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Node.js",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
      },
      -- Node.js with TypeScript
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Node.js (TypeScript)",
        cwd = "${workspaceFolder}",
        runtimeExecutable = tsx_path,
        args = {},
        program = "${file}",
        sourceMaps = true,
        protocol = "inspector",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
        outFiles = { "${workspaceFolder}/dist/**/*.js" },
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        restart = true,
      },
      -- Chrome/Browser
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Launch Chrome",
        url = "http://localhost:" .. DEV_SERVER_PORTS.react,
        webRoot = "${workspaceFolder}",
        sourceMaps = true,
      },
      -- Attaching to existing process
      {
        type = "pwa-chrome",
        request = "attach",
        name = "Attach to Process",
        processId = require("dap.utils").pick_process(),
        cwd = "${workspaceFolder}",
        sourceMaps = true,
      },
    }
  end
end

--- Setup Vue.js debugging
---@param dap table DAP instance
local function setup_vue(dap)
  dap.configurations.vue = {
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Launch Vue.js app",
      url = "http://localhost:" .. DEV_SERVER_PORTS.vue,
      webRoot = "${workspaceFolder}",
      sourceMaps = true,
    },
  }
end

--- Setup .NET debugging
---@param dap table DAP instance
local function setup_dotnet(dap)
  local netcoredbg_path = get_netcoredbg_path()

  if not is_executable(netcoredbg_path) then
    log_warning("Warning: netcoredbg not found at " .. netcoredbg_path)
  end

  -- Setup adapter
  dap.adapters.coreclr = {
    type = "executable",
    command = netcoredbg_path,
    args = { "--interpreter=vscode" },
  }

  -- Ensure C# filetype is recognized
  vim.filetype.add({
    extension = { cs = "cs" },
    pattern = { [".*%.cs$"] = "cs" },
  })

  -- Configure C# debugging
  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "Launch .NET Core Program",
      request = "launch",
      program = function()
        local default_path = find_dotnet_dll()
        return vim.fn.input("Path to dll: ", default_path, "file")
      end,
      cwd = "${workspaceFolder}",
      stopAtEntry = true,
      console = "integratedTerminal",
      justMyCode = true,
      logging = {
        engineLogging = true,
        moduleLoad = true,
        programOutput = true,
        exceptions = true,
      },
    },
    {
      type = "coreclr",
      name = "Attach to Process",
      request = "attach",
      processId = require("dap.utils").pick_process,
      sourceMaps = true,
    },
    {
      type = "coreclr",
      name = "Launch .NET Core Test",
      request = "launch",
      program = function()
        local default_path = vim.fn.getcwd() .. "/bin/Debug/"
        return vim.fn.input("Path to dll: ", default_path, "file")
      end,
      cwd = "${workspaceFolder}",
      stopAtEntry = false,
      console = "integratedTerminal",
      args = { "--filter", "${input:testName}" },
    },
  }
end

-- ================================================================================
-- Main plugin Configuration
-- ================================================================================

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "mxsdev/nvim-dap-vscode-js",
    {
      "microsoft/vscode-js-debug",
      build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    },
    "Cliffback/netcoredbg-macOS-arm64.nvim",
  },
  config = function()
    local dap = require("dap")

    -- Setup UI Elements (signs and highlights)
    setup_dap_ui()

    -- Setup Language-Specific configurations
    setup_js_typescript(dap)
    setup_vue(dap)
    setup_dotnet(dap)

    -- Log successful setup
    vim.notify("DAP configured successful", vim.log.levels.INFO)
  end,
}
