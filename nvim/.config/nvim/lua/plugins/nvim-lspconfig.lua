return {
  "neovim/nvim-lspconfig",
  opts = {
    capabilities = {
      general = {
        positionEncodings = { "utf-16" },
      },
    },
    servers = {
      tailwindcss = {
        -- Tailwindcss Language Server configuration
        root_dir = function(...)
          return require("lspconfig.util").root_pattern(
            "tailwind.config.js",
            "tailwind.config.ts",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.json",
            "postcss.config.js",
            "postcss.config.ts",
            "postcss.config.cjs",
            "postcss.config.mjs"
          )(...)
        end,
        settings = {
          tailwindCSS = {
            -- Enable completions for class names
            classAttributes = {
              "class",
              "className",
              "classList",
              "ngClass",
              "class:list",
            },
            -- Include Language support
            includeLanguages = {
              eelixir = "html-eex",
              eruby = "erb",
              htmlangular = "html",
              templ = "html",
              svelte = "html",
              vue = "html",
              astro = "html",
            },
            -- Validate CSS
            validate = true,
            -- Lint CSS
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidConfigPath = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning",
            },
            -- Experimental features
            experimental = {
              classRegex = {
                -- Enable class detection in more contexts
                "tw`([^`]*)", -- tw`...`
                'tw="([^"]*)', -- tw="..."
                'tw={"([^"}]*)', -- tw={"..."}
                "tw\\.\\w+`([^`]*)", -- tw.div`...`
                "tw\\(.*?\\)`([^`]*)", -- tw(...)`...`
                { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { "classnames\\(([^)]*)\\)", "'([^']*)'" },
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
          },
        },
      },
      omnisharp = {
        settings = {
          FormattingOptions = {
            OrganizeImports = true,
          },
          MsBuild = {
            LoadProjectsOnDemand = false,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            EnableDecompilationSupport = true,
            AnalyzeOpenDocumentsOnly = false,
          },
        },
      },
      biome = {
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git")(fname)
        end,
        single_file_support = true,
        settings = {
          biome = {
            enabled = true,
          },
        },
      },
      vtsls = {
        settings = {
          typescript = {
            format = {
              enable = false,
            },
          },
          typescriptreact = {
            format = {
              enable = false,
            },
          },
        },
      },
      sqlls = {
        cmd = { "sql-language-server", "up", "--method", "stdio" },
        filetypes = { "sql", "mysql", "plsql" },
        root_dir = function(_)
          return vim.uv.cwd()
        end,
        settings = {
          sqlLanguageServer = {
            connections = {},
            lint = {
              rules = {
                ["align-column-to-the-first"] = "error",
                ["column-new-line"] = "error",
                ["linebreak-after-clause-keyword"] = "off",
                ["reserved-word-case"] = { "error", "upper" },
                ["space-surrounding-operators"] = "error",
                ["where-clause-new-line"] = "error",
                ["align-where-clause-to-the-first"] = "error",
              },
            },
          },
        },
      },
    },
  },
}
