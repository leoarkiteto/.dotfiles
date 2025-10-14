return {
  "neovim/nvim-lspconfig",
  opts = {
    capabilities = {
      general = {
        positionEncodings = { "utf-16" },
      },
      textDocument = {
        codeAction = {
          dynamicRegistration = true,
          codeActionLiteralSupport = {
            codeActionKind = {
              valueSet = {
                "",
                "quickfix",
                "refactor",
                "refactor.extract",
                "refactor.inline",
                "refactor.rewrite",
                "source",
                "source.organizeImports",
              },
            },
          },
        },
        -- Completetly disable inlay hints for all servers
        inlayHint = nil,
      },
    },
    servers = {
      -- .NET/C# Language Server (csharp-ls) - only if available
      csharp_ls = vim.fn.executable("csharp-ls") == 1
          and {
            handlers = {
              -- Disable inlay hints as they cause positioning errors with csharp-ls
              ["textDocument/inlayHint"] = function()
                return { result = {} }
              end,
            },
            on_attach = function(client)
              -- Disable inlay hint capability to prevent requests from being sent
              client.server_capabilities.inlayHintProvider = nil
            end,
          }
        or nil,

      -- .NET/C# Language Server (Omnisharp) - fallback when csharp-ls not available
      omnisharp = vim.fn.executable("csharp-ls") == 0
          and {
            mason = true, -- Auto-install via Mason
            root_dir = function(fname)
              local root = require("lspconfig.util").root_pattern(
                "*.sln",
                "*.csproj",
                "*.fsproj",
                "*.vbproj",
                "global.json",
                "Directory.Build.props",
                "Directory.Build.targets",
                "nuget.config",
                ".git"
              )(fname)

              -- Fallback to current directory if no project files found
              return root or vim.fn.getcwd()
            end,
            cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
            settings = {
              FormattingOptions = {
                OrganizeImports = true,
                EnableEditorConfigSupport = true,
              },
              MsBuild = {
                LoadProjectsOnDemand = true,
              },
              RoslynExtensionsOptions = {
                EnableAnalyzersSupport = true,
                EnableImportCompletion = true,
                EnableDecompilationSupport = true,
                AnalyzeOpenDocumentsOnly = false,
                EnableEditorConfigSupport = true,
                DocumentAnalysisTimeoutMs = 30000,
                -- Completetly disable inlay hints at the server level
                inlayHintsOptions = {
                  enableForParameters = false,
                  enableForTypes = false,
                  enableForLiteralParameters = false,
                  enableForIndexerParameters = false,
                  enableForObjectCreationParameters = false,
                  enableForOtherParameters = false,
                  suppressForParametersThatDifferOnlyBySuffix = true,
                  suppressForParametersThatMatchIntent = true,
                  suppressForParametersThatArgumentName = true,
                },
              },
              Sdk = {
                IncludePrereleases = false,
              },
              useModerNet = true,
              enableRoslynAnalyzer = true,
              EnableEditorConfigSupport = true,
            },
            handlers = {
              -- Only disable semantic tokens if they cause problems, but keep other handlers
              ["textDocument/semanticTokens/full"] = function()
                return nil
              end,
              ["textDocument/semanticTokens/full/delta"] = function()
                return nil
              end,
              -- Didable inlay hints as they cause positioning errors with omnisharp
              ["textDocument/inlayHint"] = function()
                return { result = {} }
              end,
            },
            on_attach = function(client)
              -- Only disable semantic tokens, keep other capabilities
              client.server_capabilities.semanticTokensProvider = nil
              -- Disable inlay hints capability to prevent requests from being sent
              client.server_capabilities.inlayHintProvider = nil
            end,
            -- Add init_options for better startup
            init_options = {
              AutomaticWorkspaceInit = true,
            },
          }
        or nil,
      -- Tailwindcss Language Server
      tailwindcss = {
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
      -- Dart Language Server for Flutter development
      -- Note: dartls comes with Dart SDK, install via: brew install dart (macOS) or download from dart.dev
      dartls = vim.fn.executable("dart") == 1
          and {
            root_dir = function(fname)
              return require("lspconfig.util").root_pattern(
                "pubspec.yaml",
                "pubspec.yml",
                "analysis_options.yaml",
                ".git"
              )(fname)
            end,
            settings = {
              dart = {
                enableSdkFormater = true,
                lineLength = 120,
                completeFunctionCalls = true,
                showTodos = true,
                analysisExcludeFolders = {},
                updateImportOnRename = true,
                enableSnippets = true,
                -- Add robust error handling settings
                analysisSeverFolding = true,
                analysisSeverSnippets = true,
                -- Reduce analysis server load to prevent crashes
                onlyAnalyzeProjectsWithOpenFiles = true,
                -- Disable some features that can cause RangeError issues
                enableServerSnippets = false,
                -- Add timeout settings
                analysisServerTimeout = 30,
              },
            },
            init_options = {
              onlyAnalyzeProjectsWithOpenFiles = true,
              suggestFromUnimportedLibraries = true,
              closingLabels = true,
              -- Add more robust initialization options
              enableSnippets = false, -- Disable snippets to reduce complexity
              enableServerSnippets = false,
            },
            -- Add error handling and recovery
            handlers = {
              -- Handle text document changes more gracefully
              ["textDocument/didChange"] = function(err, result, ctx, config)
                -- Add error handling for didChange to prevent RangeError crashes
                local ok, res = pcall(function()
                  return vim.lsp.handlers["textDocument/didChange"](err, result, ctx, config)
                end)
                if not ok then
                  vim.notify("Dart LSP didChange error: " .. tostring(res), vim.log.levels.WARN)
                  -- Restart the client if it's consistently failing
                  vim.defer_fn(function()
                    vim.cmd("LspRestart")
                  end, 1000)
                end
                return res
              end,
            },
            on_attach = function(client, bufnr)
              -- Add client restart capability
              local function restart_dartls()
                vim.notify("Restarting Dart LSP...", vim.log.levels.INFO)
                vim.cmd("LspRestart")
              end

              -- Add keymap to manually restart dartls if needed
              vim.keymap.set("n", "<leader>dr", restart_dartls, {
                buffer = bufnr,
                desc = "Restart Dart LSP",
                silent = true,
              })

              -- Monitor for client errors and restart if needed
              client.on_exit = function(code, signal)
                if code ~= 0 or signal ~= 0 then
                  vim.notify(
                    "Dart LSP exited unexpectedly (code: " .. code .. ", signal: " .. signal .. "). Restarting...",
                    vim.log.levels.WARN
                  )
                  vim.defer_fn(restart_dartls, 2000)
                end
              end
            end,
            --- Add more robust capabilities
            capabilities = {
              textDocument = {
                -- Disable some features that can cause issues
                inlayHint = nil,
                -- Reduce semantic token complexity
                semantiTokens = {
                  dynamicRegistration = false,
                },
              },
            },
          }
        or nil,
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
