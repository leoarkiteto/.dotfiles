return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- dressing.nvim is optional and only needed for vim.ui.select enhancements
    -- Remove this line if you don't use dressing.nvim
    -- "stevearc/dressing.nvim",
  },
  config = function()
    require("flutter-tools").setup({
      ui = {
        -- the border type to use for all floating windows, the same options/formats
        -- used for ":h nvim_open_win" e.g. "single" | "shadow" | {<table-of-eight-chars>}
        border = "rounded",
        -- This determines whether notifications are show with `vim.notify` or with the plugin's custom UI
        -- please note that this option is eventually going to be deprecated and users will need to
        -- use dependent plugins due to its usage of deprecated APIs.
        notification_style = "plugin",
      },
      decorations = {
        statusline = {
          -- set to true to be able use the 'flutter-tools_decorations.app_version' in your statusline
          -- this will show the current version of the flutter app from the pubspec.yaml file
          app_version = true,
          -- set to true to be able use the 'flutter-tools_decorations.device' in your statusline
          -- this will show the currently selected device in your statusline
          device = true,
          -- set to true to be able use the 'flutter-tools_decorations.project_config' in your statusline
          -- this will show the currently selected project configuration
          project_config = true,
        },
      },
      debugger = {
        -- make sure you have run the "flutter create ." in the project root before using
        enabled = true,
        -- set to true to enable debug logging
        run_via_dap = true, -- use dap instead of a plenary job to run flutter apps
        -- if empty app will not stop on any exceptions, otherwise it will stop on those specified
        -- see |:help dap.set_exception_breakpoints()| for more info
        exception_breakpoints = {},
        -- register_configurations = function(paths)
        --   require("dap").configuration.dart = {
        --     <put here config that you would find in .vscode/launch.json>
        --   }
        -- end,
      },
      fvm = false, -- takes longer to start up so you can disable it if you don't use fvm
      widget_guides = {
        enabled = true,
      },
      closing_tags = {
        highlight = "ErrorMsg", -- highlight for the closing tag
        prefix = ">", -- character to use for close tag e.g. > Widget
        enabled = true, -- set to false to disable
      },
      dev_log = {
        enabled = true,
        notifiy_errors = false, -- if there is an error whilst running then notify the user
        open_cmd = "tabedit", -- command to use to open the log buffer
      },
      dev_tools = {
        autostart = false, -- autostart devtools server if not detected
        auto_open_browser = false, -- Automatically opens devtools in the browser
      },
      outline = {
        open_cmd = "30vnew", -- command to use to open the outline buffer
        auto_open = false, -- if true this will open the outline automatically when it is first available
      },
      lsp = {
        color = { -- show the derived colours for dart variables
          enabled = false, -- whether or not to highlight color variables at all, only supported on flutter >=
          background = false, -- highlight the background
          foreground = false, -- highlight the foreground
          virtual_text = true, -- show the highlight using virtual text
          virtual_text_str = "📦", -- the virtual text character to highlight
        },
        -- see the link below for details on each option:
        -- https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#client-workspace-configuration
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          analysisExcludedFolders = {},
          renameFilesWithClasses = "prompt", -- "always"
          enableSnippets = false, -- Disable snippets to prevent RangeError issues
          updateImportsOnRename = true, -- Whether to update imports and other directives when files are renamed. Required for `Flutter: Rename to snake_case`
          lineLength = 120,
          -- Add robust settings to prevent crashes
          onlyAnalyzeProjectsWithOpenFiles = true,
          enableSeverSnippets = false,
          analysisServerTimeout = 30,
        },
        -- Add error handling for Flutter tools LSP
        on_attach = function(client, bufnr)
          -- Add restart functionality for Flutter LSP
          local function restart_flutter_lsp()
            vim.notify("Restarting Flutter LSP...", vim.log.levels.INFO)
            vim.cmd("LspRestart")
          end

          -- Add keymap to restart Flutter LSP
          vim.keymap.set("n", "<leader>fr", restart_flutter_lsp, {
            buffer = bufnr,
            desc = "Restart Flutter LSP",
            silent = true,
          })

          -- Monitor for client crashes
          client.on_exit = function(code, signal)
            if code ~= 0 or signal ~= 0 then
              vim.notify(
                "Flutter LSP exited unexpectedly (code: " .. code .. ", signal: " .. signal .. "). Restarting...",
                vim.log.levels.WARN
              )
              vim.defer_fn(restart_flutter_lsp, 2000)
            end
          end
        end,
      },
    })
  end,
}
