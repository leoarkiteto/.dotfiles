---@diagnostic disable: missing-fields
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "Cliffback/netcoredbg-macOS-arm64.nvim",
      "mxsdev/nvim-dap-vscode-js",
      {
        "microsoft/vscode-js-debug",
        -- Ensure this matches the version you want
        build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
      },
      -- Golang
      "leoluz/nvim-dap-go",
      -- .NET
      "Cliffback/netcoredbg-macOS-arm64.nvim",
    },
    config = function()
      local dap = require("dap")

      -- Define signs for debugging
      vim.fn.sign_define("DapBreakpoint", {
        text = "󰀚", -- Use '󰀚', or '⬤' for red circle
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆", -- Use '◆' or '◆' for condition
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "󱚍", -- Use '󱚍' or '◆' for logpoint
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "󰁔", -- Use '󰁔' or '▶' for current position
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "󰅖", -- Use '󰅖' or '●' for rejected breakpoint
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

      -- ======== JS/TS ======== --
      require("dap-vscode-js").setup({
        -- Path to vscode-js-debug installation
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        -- Use node by default, but you can override per adapter
        adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
        -- Which filetypes to enable
        preserve_window_dimensions = true,
      })

      local function get_tsx_path()
        local global_tsx = vim.fn.trim(vim.fn.system("whick tsx"))
        if vim.v.shell_error == 0 and global_tsx ~= "" then
          return global_tsx
        end

        local local_tsx = vim.fn.getcwd() .. "/node_modules/.bin/tsx"
        if vim.fn.filereadable(local_tsx) == 1 then
          return local_tsx
        end

        return "tsx"
      end

      local tsx_path = get_tsx_path()

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
              runtimeExecutable = tsx_path,
              args = {},
              program = "${file}",
              sourceMaps = true,
              protocol = "inspector",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
              outFile = { "${workspaceFolder}/dist/**/*.js" },
              console = "integratedTerminal",
              internalConsoleOptions = "neverOpen",
              restart = true,
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

      -- ======== Go ======== --
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

      -- ======== .NET ======== --
      local function log_msg(msg)
        vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
      end
      local netcoredbg_path = vim.fn.stdpath("data") .. "/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg"
      log_msg(netcoredbg_path)

      if vim.fn.executable(netcoredbg_path) ~= 1 then
        log_msg("Warning: netcoredbg not found at " .. netcoredbg_path)
      end

      dap.adapters.coreclr = {
        type = "executable",
        command = netcoredbg_path,
        args = { "--interpreter=vscode" },
      }

      vim.filetype.add({
        extension = {
          cs = "cs",
        },
        pattern = {
          [".*%s.cs$"] = "cs",
        },
      })
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET Core Program",
          request = "launch",
          program = function()
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            local possible_paths = {
              string.format("%s/bin/Debug/net7.0/%s.dll", vim.fn.getcwd(), project_name),
              string.format("%s/bin/Debug/net8.0/%s.dll", vim.fn.getcwd(), project_name),
              string.format("%s/bin/Debug/net9.0/%s.dll", vim.fn.getcwd(), project_name),
            }
            local default_path = nil

            for _, path in ipairs(possible_paths) do
              if vim.fn.filereadable(path) == 1 then
                default_path = path
                break
              end
            end
            if default_path == nil then
              default_path = possible_paths[1]
              log_msg("Default DLL path: " .. default_path)
            end

            return vim.fn.input("Path to dll: ", default_path, "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = true,
          console = "integratedTerminal",
          justMyCode = true,
          logging = {
            engineLogging = true,
            moduleLoad = true,
            programOutput = true,
            exceptions = true,
          },
        },
        {
          type = "coreclr",
          name = "Attach to Process",
          request = "attach",
          processId = require("dap.utils").pick_process,
          sourceMaps = true,
        },
        {
          type = "coreclr",
          name = "Launch .NET Core Test",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cmd = "${workspaceFolder}",
          stopAtEntry = false,
          console = "integratedTerminal",
          args = { "--filter", "${input:testName}" },
        },
      }
    end,
  },
}
