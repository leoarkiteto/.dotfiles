return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      -- Go development
      "gopls", -- Go LSP
      "gofumpt", -- Stricter Go formatter
      "goimports-reviser", -- Go imports formatter
      "golines", -- Go line length formatter
      "golangci-lint", -- Go linter
      "delve", -- Go debugger

      -- Web Development
      "html-lsp", -- HTML LSP
      "css-lsp", -- CSS LSP
      "biome", -- JS/TS formatter
      "prettierd", -- HTML/CSS/JS formatter daemon (faster than prettier)
      "eslint_d", -- Fast ESLint daemon for linting

      -- Database
      "sqlls", -- SQL LSP
      "sqlfluff", -- SQL formatter and linter

      -- Markdown & Configuration
      "yaml-language-server", -- YAML LSP
      "marksman", -- Markwdown LSP
      "taplo", -- TOML LSP

      -- General development Tools
      "stylua", -- Lua formatter
      "shellcheck", -- Shell script linter
      "shfmt", -- Shell script formatter
    },
    ui = {
      border = "rounded",
      width = 0.8,
      height = 0.8,
      icons = {
        package_installed = "",
        package_pending = "",
        package_uninstalled = "",
      },
    },
    pip = {
      upgrade_pip = true,
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 4,
  },
  config = function(_, opts)
    require("mason").setup(opts)

    -- Ensure critical development tools are prioritized
    local registry = require("mason-registry")

    -- Auto-install critical web tools if missing
    local critical_tools = { "prettierd", "eslint_d" }

    for _, tool in ipairs(critical_tools) do
      local package = registry.get_package(tool)
      if not package:is_installed() then
        vim.notify(string.format("Installing critical development tool: %s", tool), vim.log.levels.INFO)
        package:install()
      end
    end
  end,
}
