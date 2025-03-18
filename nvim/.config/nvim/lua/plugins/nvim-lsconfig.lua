return {
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "Hoffs/omnisharp-extended-lsp.nvim",
    },
    opts = function(_, opts)
      local omnisharp_extended_status, omnisharp_extended = pcall(require, "omnisharp_extended")

      -- Initialize servers table if it doesn't exist
      opts.servers = opts.servers or {}

      -- Setup OmniSharp
      opts.servers.omnisharp = {
        cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        -- Only use extended handler if the plugin is available
        handlers = omnisharp_extended_status and {
          ["textDocument/definition"] = omnisharp_extended.handler,
        } or nil,
        -- Unity-specific settings
        settings = {
          omnisharp = {
            useModernNet = true,
            monoPath = "", -- Set this to your Unity Mono path if needed
            useGlobalMono = "always",
            analyzeOpenDocumentsOnly = false,
            automaticWorkspaceInit = true,
            enableMsBuildLoadProjectsOnDemand = true,
            enableRoslynAnalyzers = true,
            enableImportCompletion = true,
            organizeImportsOnFormat = true,
            sdkPath = vim.fn.expand("$HOME/.dotnet/sdk/9.0.200"),
            -- Unity-specific analyzers
            analyzerAssemblyExcludePaths = {
              vim.fn.expand("$HOME/.local/share/JetBrains/Rider/Plugins/Unity"),
            },
          },
        },
        init_options = {
          useModernNet = true,
          -- For Unity 6 with .NET 9
          msbuildLoadProjectsOnDemand = true,
          enableMsBuildLoadProjectsOnDemand = true,
          enableRoslynAnalyzers = true,
          analyzeOpenDocumentsOnly = false,
        },
      }

      return opts
    end,
  },
}
