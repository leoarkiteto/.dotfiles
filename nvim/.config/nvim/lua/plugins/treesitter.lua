return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    ensure_installed = {
      "go", -- Go language support
      "gomod",
      "gowork",
      "gosum",
      "xml", -- For config files
      "yaml", -- For docker-compose, GitHub Actions
      "json", -- For config files, package.json
      "dockerfile", -- For containerized apps
      "toml", -- For .editorconfig

      -- Web Development
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

      -- Game Development (Godot)
      "gdscript",
      "godot_resource",
      "gdshader",
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
