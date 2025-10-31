return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    ensure_installed = {
      -- .NET Development
      "c_sharp", -- C# language support
      "xml", -- For .csproj, config files
      "yaml", -- For docker-compose, GitHub Actions
      "json", -- For appsettings.json, package.json
      "dockerfile", -- For containerized .NET apps
      "toml", -- For .editorconfig, global.json

      -- Web Development (for full-stack .NET)
      "html",
      "css",
      "scss",
      "javascript",
      "typescript",
      "tsx",
      "vue",
      "svelte",

      -- Database & API
      "sql",
      "graphql",
      "http", -- For .http files

      -- DevOps & Configuration
      "bash",
      "regex",
      "gitignore",
      "gitcommit",
      "gitattributes",

      -- Documentation
      "markdown",
      "markdown_inline",

      -- Development Tools
      "lua", -- For Neovim config
      "vim", -- For Neovim config
      "query", -- For custom Treesitter queries

      -- Game Development
      "gdscript", -- Godot scripting language
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "markdown" }, -- Better markdown suuport
    },
    indent = {
      enable = true,
      disable = { "yaml" }, -- YAML indentation can be problematic
    },
  },
}
