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
      if vim.fn.filereadable(vim.fn.join({ dir, config_file }, "/")) == 1 then
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
  -- Try eslint_d first, fallback to biome for projects without eslint config
  if has_eslint_config(file_path) then
    return { "eslint_d" }
  else
    -- For projects without eslint, use biome as fallback
    return { "biomejs" }
  end
end

return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      -- Go development
      go = { "golangcilint" },

      -- Web technologies (prefer eslint_d, fallback to Biome for non-eslint projects)
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      vue = { "eslint_d" },
      json = { "eslint_d" }, -- ESLint can handle JSON with proper config
      jsonc = { "eslint_d" },

      -- Database
      sql = { "sqlfluff" },

      -- Markdown
      markdown = { "markdownlint-cli2" },
      yaml = { "yamllint" },
      gdscript = { "gdlint" },
    },
    linters = {
      gdlint = {
        cmd = "gdlint",
        stdin = false,
        ignore_exitcode = true,
        args = {
          function()
            return vim.fn.expand("%:p")
          end,
        },
        stream = "stdout",
        parser = function(output, bufnr)
          local diagnostics = {}

          -- GDLint output format: file:line:column: severity: message
          -- Example: script.gd:10:5: Error: Unused variable 'player'
          for line in output:gmatch("[^\r\n]+") do
            local file, line_num, col, severity, message = line:match("([^:]+):(%d+):(%d+):%s*(%w+):%s*(.+)")

            if line_num and message then
              local diagnostic_severity = vim.diagnostic.severity.INFO
              if severity and severity:lower() == "error" then
                diagnostic_severity = vim.diagnostic.severity.ERROR
              elseif severity and severity:lower() == "warning" then
                diagnostic_severity = vim.diagnostic.severity.WARN
              end

              table.insert(diagnostics, {
                lnum = tonumber(line_num) - 1,
                col = tonumber(col or 0) - 1,
                severity = diagnostic_severity,
                message = message,
                source = "gdlint",
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

    -- Auto-lint on save and text change
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local ft = vim.bo.filetype
        -- Update web linters based on current project
        if vim.tbl_contains({ "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }, ft) then
          update_web_linters()
        end
        lint.try_lint()
      end,
    })
  end,
}
