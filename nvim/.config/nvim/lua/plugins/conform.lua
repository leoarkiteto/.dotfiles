-- ============================================
-- Utility Functions
-- ============================================

--- Check if a command is available in PATH
---@param cmd string|nil
---@return boolean
local function is_available(cmd)
  return cmd ~= nil and type(cmd) == "string" and vim.fn.executable(cmd) == 1
end

--- Get available formatters from a list with context awareness
--- @param formatters table List of formatters names
--- @param context table|nil Optional context with file path information
--- @return table Available formatters
local function filter_available_formatters(formatters, context)
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
    local is_cmd_available = cmd == true or is_available(cmd)

    if is_cmd_available then
      -- For biome, also check if we're in a project than can use it
      if formatter == "biome" then
        local current_file = context and context.filename or vim.api.nvim_buf_get_name(0)
        if current_file ~= "" then
          -- Simple project detection by looking for common JS/TS project files
          local function find_project_root(file_path)
            local dir = vim.fn.fnamemodify(file_path, ":h")
            local project_files = { "package.json", "biome.json", "biome.jsonc", "tsconfig.json", "jsconfig.json" }

            -- Search up the directory tree
            while dir and dir ~= "/" do
              for _, project_file in ipairs(project_files) do
                if vim.fn.filereadable(vim.fn.join({ dir, project_file }, "/")) == 1 then
                  return dir
                end
              end
              local parent = vim.fn.fnamemodify(dir, ":h")
              if parent == dir then
                break
              end
              dir = parent
            end
            return nil
          end

          if find_project_root(current_file) then
            table.insert(available, formatter)
          end
        end
      else
        table.insert(available, formatter)
      end
    end
  end

  return available
end

-- ============================================
-- Custom Formatter Configuration
-- ============================================

local formatters = {}

-- Biome formatter with proper root detection
formatters.biome = {
  cwd = function(self, ctx)
    -- Find project root by looking for common JS/TS project files
    local current_file = ctx.filename
    local dir = vim.fn.fnamemodify(current_file, ":h")
    local project_files = { "package.json", "biome.json", "biome.jsonc", "tsconfig.json", "jsconfig.json" }

    -- Search up the directory tree
    while dir and dir ~= "/" do
      for _, project_file in ipairs(project_files) do
        if vim.fn.filereadable(vim.fn.join({ dir, project_file }, "/")) == 1 then
          return dir
        end
      end
      local parent = vim.fn.fnamemodify(dir, ":h")
      if parent == dir then
        break
      end
      dir = parent
    end

    -- Fallback to file directory if no project root found
    return vim.fn.fnamemodify(current_file, ":h")
  end,
}

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
  formatters_by_ft[ft] = function(bufnr)
    local context = { filename = vim.api.nvim_buf_get_name(bufnr) }
    local available = filter_available_formatters({ "biome", "prettier" }, context)
    return #available > 0 and { available[1] } or {}
  end
end

-- C# (only if available)
if is_available("csharpier") then
  formatters_by_ft.cs = { "csharpier" }
end

-- XML (only if available)
if is_available("xmllint") then
  formatters_by_ft.xml = { "xmllint" }
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

  -- Notify on format errors
  notify_on_error = true,
}
