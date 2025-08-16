return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      -- .NET/C# linting
      cs = { "dotnet_format" }, -- Use dotnet format for C# linting

      -- Web technologies
      typescript = { "biomejs" },
      typescriptreact = { "biomejs" },
      vue = { "biomejs" },
      json = { "biomejs" },
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

    -- Auto-lint on save and text change for .NET files
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local ft = vim.bo.filetype
        -- Only auto-lint for non-C# files (C# uses LSP for most diagnostics)
        if ft ~= "cs" then
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
