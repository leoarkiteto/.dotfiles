return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.formatters = opts.formatters or {}
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    -- Existing formatters configuration
    opts.formatters.cs = {
      csharpier = {
        command = "dotnet-csharpier",
        args = { "--write-stdout" },
      },
    }
    opts.formatters["markdown-toc"] = {
      condition = function(_, ctx)
        for _, line in ipairs(vim.api.nvim__get_lines(ctx.buf, 0, -1, false)) do
          if line:find("<!%-%- toc %-%->") then
            return true
          end
        end
      end,
    }
    opts.formatters["markdownlint-cli2"] = {
      condition = function(_, ctx)
        local diag = vim.tbl_filter(function(d)
          return d.source == "markdownlint"
        end, vim.diagnostic.get(ctx.buf))
        return #diag > 0
      end,
    }

    -- Add sqlfluff formatter configuration
    opts.formatters.sqlfluff = {
      args = { "format", "--dialect=ansi", "-" },
    }

    -- Define SQL file types
    local sql_ft = { "sql", "mysql", "plsql", 'plsql' }

    -- Set formatters by file type
    opts.formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
      cs = { "csharpier" },
      ["markdown"] = { "prettierd", "prettier", "markdownlint-cli2", "markdown-toc" },
      ["markdown.mdx"] = { "prettierd", "prettier", "markdownlint-cli2", "markdown-toc" },
    }

    -- Add sqlfluff to SQL file types
    for _, ft in ipairs(sql_ft) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      table.insert(opts.formatters_by_ft[ft], "sqlfluff")
    end

    return opts
  end,
}
