-- ============================================
-- Utility Functions
-- ============================================

--- Check if a command is available in PATH
---@param cmd string|nil
---@return boolean
local function is_available(cmd)
  return cmd ~= nil and type(cmd) == "string" and vim.fn.executable(cmd) == 1
end

--- Get available formatters from a list
--- @param formatters table List of formatters names
--- @return table Available formatters
local function filter_available_formatters(formatters)
  local available = {}

  -- Known commad mappings for formatters
  local formatter_commads = {
    biome = "biome",
    prettier = "prettier",
    stylua = "stylua",
    yamlfmt = "yamlfmt",
    csharpier = "csharpier",
    xmllint = "xmllint",
    sqlfluff = "sqlfluff",
    shfmt = "shfmt",
    injected = true,
  }

  for _, formatter in ipairs(formatters) do
    local cmd = formatter_commads[formatter]
    if cmd == true or is_available(cmd) then
      table.insert(available, formatter)
    end
  end

  return available
end

-- ============================================
-- Custom Formatter Configuration
-- ============================================

local formatters = {}

-- C# formatter
if is_available("csharpier") then
  formatters.csharpier = {
    command = "csharpier",
    args = { "format" },
    stdin = true,
  }
end

-- XML formatter
if is_available("xmllint") then
  formatters.xmllint = {
    command = "xmllint",
    args = { "--format", "-" },
    stdin = true,
  }
end

-- SQL formatter (only if in a project with SQL files)
if is_available("sqlfluff") then
  formatters.sqlfluff = {
    command = "sqlfluff",
    args = { "--format", "--dialect=postgres", "-" },
    stdin = true,
    -- Make cwd optional - fallback to current directory if no config found
    cwd = function(self, ctx)
      local root = require("conform.util").root_file({
        ".sqlfluff",
        "pyproject.toml",
        "setup.cfg",
        "tox.ini",
      })(self, ctx)
      return root or ctx.dirname
    end,
  }
end

-- ============================================
-- Formatters by File Type
-- ============================================

local formatters_by_ft = {}

-- Web technologies (prefer biome, fallback to prettier)
local web_filetypes = { "html", "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "jssonc" }
for _, ft in ipairs(web_filetypes) do
  local available = filter_available_formatters({ "biome", "prettier" })
  if #available > 0 then
    formatters_by_ft[ft] = { available[1] } -- Use first available
  end
end

-- C# (only if available)
if is_available("csharpier") then
  formatters_by_ft.cs = { "csharpier" }
end

-- XML (only if available)
if is_available("xmllint") then
  formatters_by_ft.xmls = { "xmllint" }
end

-- Lua (only if available)
if is_available("stylua") then
  formatters_by_ft.lua = { "stylua" }
end

-- Markdown (use inected formatting for better results)
formatters_by_ft.markdown = { "injected" }
formatters_by_ft["markdow.mdx"] = { "injected" }

-- YAML (prefer yamlfmt, fallback to prettier)
local yaml_available = filter_available_formatters({ "yamlfmt", "prettier" })
if #yaml_available > 0 then
  formatters_by_ft.yml = { yaml_available[1] }
  formatters_by_ft.yaml = { yaml_available[1] }
end

-- SQL (only if available and in appropriate project)
if is_available("sqlfluff") then
  formatters_by_ft.sql = { "sqlfluff" }
end

-- Shell scripts (if shfmt is available)
if is_available("shfmt") then
  formatters_by_ft.sh = { "shfmt" }
  formatters_by_ft.bash = { "shfmt" }
end

-- ============================================
-- Return Configuration
-- ============================================

return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters = formatters,
    formatters_by_ft = formatters_by_ft,

    -- Default format options
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
    },

    -- Notify on format errors
    notify_on_error = true,
  },
}
