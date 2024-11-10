---@diagnostic disable: missing-fields
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mxsdev/nvim-dap-vscode-js",
      {
        "microsoft/vscode-js-debug",
        -- Ensure this matches the version you want
        build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
      },
      -- Golang
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      -- Define signs for debugging
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴", -- Use '🔴' or '⬤' for red circle
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🔶", -- Use '🔶' or '◆' for condition
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "📝", -- Use '📝' or '◆' for logpoint
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "⇒", -- Use '⇒' or '▶' for current position
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "❌", -- Use '❌' or '●' for rejected breakpoint
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = "",
      })
      -- Add highlight groups
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#993939" }) -- Red color
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#F79000" }) -- Orange color
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61AFEF" }) -- Blue color
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98C379" }) -- Green color
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#E06C75" }) -- Light red color
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#31353f" }) -- Dark background for current line

      -- Configure JavaScript/TypeScript debugging
      require("dap-vscode-js").setup({
        -- Path to vscode-js-debug installation
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        -- Use node by default, but you can override per adapter
        adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
        -- Which filetypes to enable
        preserve_window_dimensions = true,
      })

      -- Configure different JavaScript environments
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }) do
        if language == "vue" then
          dap.configurations[language] = {
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch Vue.js app",
              url = "http://localhost:5173", -- default Vite dev server port
              webRoot = "${workspaceFolder}",
              sourceMaps = true,
            },
          }
        else
          dap.configurations[language] = {
            -- Node.js
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node.js",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
            -- Node.js with TypeScript
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Node.js (TypeScript)",
              cwd = "${workspaceFolder}",
              --NOTE: You would need to have 'tsx' installed globally
              runtimeExecutable = "tsx",
              args = { "${file}" },
              protocol = "inspector",
              sourceMaps = true,
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            },
            -- Chrome/Browser
            {
              type = "pwa-chrome",
              request = "launch",
              name = "Launch Chrome",
              url = "http://localhost:3000", -- adjust port as needed
              webRoot = "${workspaceFolder}",
              sourceMaps = true,
            },
            -- Attach to existing process
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to Process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
          }
        end
      end

      -- Configure Golang debugging
      require("dap-go").setup({
        -- defaults
        dap_configurations = {
          {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}",
          },
          {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}",
          },
          {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
          },
        },
        -- Additional configurations
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
        },
      })
    end,
  },
}
