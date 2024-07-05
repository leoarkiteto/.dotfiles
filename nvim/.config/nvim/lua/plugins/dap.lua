return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "microsoft/vscode-js-debug",
      build = "pnpm install && pnpm dlx gulp vsDebugServerBundle && mv dist out",
    },
    {
      "mxsdev/nvim-dap-vscode-js",
      config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("dap-vscode-js").setup({
          --node_path = "node",
          --debugger_cmd = {"js-debug-adapter"},
          adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "pwa-extenstionHost", "node-terminal", "node", "chrome" },
          debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
          -- log_file_path = '(stdpath cache)/dap_vscode_js.log',
          -- log_file_level = false,
          -- log_console_level = vim.log.levels.ERROR
        })

        local languages = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }
        local dap = require("dap")

        for _, language in ipairs(languages) do
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch with tsx",
              cwd = "${workspaceFolder}",
              -- NOTE: You would need to have 'tsx' installed globally
              runtimeExecutable = "tsx",
              args = { "${file}" },
              sourceMaps = true,
              protocol = "inspector",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            },
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch * & Debug Chrome",
              url = function()
                local co = coroutine.running()
                return coroutine.create(function()
                  vim.ui.input({
                    prompt = "Enter URL: ",
                    default = "http://localhost:3000",
                  }, function(url)
                    if url == nil or url == "" then
                      return
                    else
                      coroutine.resume(co, url)
                    end
                  end)
                end)
              end,
              webRoot = "${workspaceFolder}",
              skipFiles = { "<node_internals>/**/*.js" },
              protocol = "inspector",
              userDataDir = false,
            },
          }
        end
      end,
    },
  },
}
