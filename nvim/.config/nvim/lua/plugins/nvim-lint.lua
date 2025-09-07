-- =================================================================
-- Smart Linter Selection
-- =================================================================

--- Check if ESLint is configured in the current project
--- @param file_path string
--- @return boolean
local function has_eslint_config(file_path)
  local dir = vim.fn.fnamemodify(file_path, ":h")
  local eslint_configs = {
    "eslint.config.mjs",
    "eslint.config.js",
    "eslint.config.cjs",
    "eslintrc.js",
    "eslintrc.cjs",
    "eslintrc.mjs",
    "eslintrc.json",
    "eslintrc.yml",
    "eslintrc.yaml",
    "eslintrc",
  }

  -- Search up the directory tree
  while dir and dir ~= "/" do
    -- Check for eslint config files
    for _, config_file in ipairs(eslint_configs) do
      if vim.fn.filereadable(vim.fn.join({ dir, config_file }, "/")) then
        return true
      end
    end

    -- Check package.json for eslintConfig
    local package_json = vim.fn.join({ dir, "package.json" }, "/")
    if vim.fn.filereadable(package_json) == 1 then
      local content = vim.fn.readfile(package_json)
      local package_str = table.concat(content, "\n")
      if package_str:match('"eslintConfig"') then
        return true
      end
    end

    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end

  return false
end

--- Smart linter selection for web technologies
---@param file_path string
---@return table
local function get_web_linters(file_path)
  if has_eslint_config(file_path) then
    return { "eslint_d" }
  else
    return { "biomejs" }
  end
end

return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      -- .NET/C# linting
      cs = { "dotnet_format" }, -- Use dotnet format for C# linting

      -- Web technologies (will be dynamically updated)
      typescript = { "biomejs" }, -- Default fallback
      typescriptreact = { "biomejs" },
      javascript = { "biomejs" },
      javascriptreact = { "biomejs" },
      vue = { "biomejs" },
      json = { "biomejs" }, -- Always use Biome for JSON (faster ans simpler)
      jsonc = { "biomejs" },

      -- Database
      sql = { "sqlfluff" },

      -- Markdown
      markdown = { "markdownlint-cli2" },
      yaml = { "yamllint" },
    },
    linters = {
      -- Custom dotnet format linter for C#
      dotnet_format = {
        name = "dotnet_format",
        cmd = "dotnet",
        stdin = false,
        args = {
          "format",
          "--verify-no-changes",
          "--verbosity",
          "diagnostic",
          function()
            return vim.fn.expand("%:p")
          end,
        },
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}

          -- Paerse dotnet format output for style vialations
          for line in output:gmatch("[^\r\n]+") do
            local file, line_num, col, severity, code, message =
              line:match("([^%(]+)%((%d+),(%d+)%)%: (%w+) (%w+): (.+)")

            if file and line_num and col and message then
              local diagnostic_severity = vim.diagnostic.severity.INFO
              if severity == "error" then
                diagnostic_severity = vim.diagnostic.severity.ERROR
              elseif severity == "warning" then
                diagnostic_severity = vim.diagnostic.severity.WARN
              end

              table.insert(diagnostics, {
                lnum = tonumber(line_num) - 1,
                col = tonumber(col) - 1,
                severity = diagnostic_severity,
                message = string.format("[%s] %s", code or "CS", message),
                source = "dotnet_format",
              })
            end
          end

          return diagnostics
        end,
      },
    },
  },
  config = function(_, opts)
    local lint = require("lint")

    -- Setup linters
    lint.linters_by_ft = opts.linters_by_ft

    -- Add custom linters
    for name, config in pairs(opts.linters or {}) do
      lint.linters[name] = config
    end

    -- Smart linter update function
    local function update_web_linters()
      local current_file = vim.api.nvim_buf_get_name(0)
      if current_file ~= "" then
        local web_linters = get_web_linters(current_file)
        local web_filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }

        for _, ft in ipairs(web_filetypes) do
          lint.linters_by_ft[ft] = web_linters
        end
      end
    end

    -- auto-lint on save and text change
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local ft = vim.bo.filetype
        -- Only auto-lint for non-C# files (C# uses LSP for most diagnostics)
        if ft ~= "cs" then
          -- Update web linters based on current project
          if vim.tbl_contains({ "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }, ft) then
            update_web_linters()
          end
          lint.try_lint()
        end
      end,
    })

    -- Manual lint command for C# (since auto-lint can be slow)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cs",
      callback = function()
        vim.keymap.set("n", "<leader>cl", function()
          lint.try_lint()
        end, { buffer = true, desc = "Lint C# File" })
      end,
    })
  end,
}
