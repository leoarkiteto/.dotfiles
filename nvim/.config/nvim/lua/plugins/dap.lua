return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "Cliffback/netcoredbg-macOS-arm64.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Setup DAP UI (deferred to avoid E565 error)
    vim.schedule(function()
      dapui.setup()
    end)

    -- Configure debug icons/signs using Nerd Font glyphs (consistent with mini.icons style)
    local icons = {
      breakpoint = "",
      breakpoint_condition = "",
      breakpoint_rejected = "",
      log_point = "",
      stopped = "",
    }

    vim.fn.sign_define("DapBreakpoint", {
      text = icons.breakpoint,
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    })

    vim.fn.sign_define("DapBreakpointCondition", {
      text = icons.breakpoint_condition,
      texthl = "DiagnosticSignWarn",
      linehl = "",
      numhl = "",
    })
    vim.fn.sign_define("DapBreakpointRejected", {
      text = icons.breakpoint_rejected,
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    })
    vim.fn.sign_define("DapLogPoint", {
      text = icons.log_point,
      texthl = "DiagnosticSignInfo",
      linehl = "",
      numhl = "",
    })
    vim.fn.sign_define("DapStopped", {
      text = icons.stopped,
      texthl = "DiagnosticSignWarn",
      linehl = "",
      numhl = "",
    })

    -- Define highlight group for stopped line
    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#555530" })

    -- Configure .NET Core debugger
    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.expand("~/.local/share/nvim/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg"),
      args = { "--interpreter=vscode" },
    }

    -- Helper function to find DLL automatically
    local function get_dll_path()
      local cwd = vim.fn.getcwd()

      -- Find .csproj file - try current directory first, then search recursively
      local csproj_files = vim.fn.glob(cwd .. "/*.csproj", false, true)

      -- If not found in current directory, search recursively (up to 3 levels deep)
      if #csproj_files == 0 then
        csproj_files = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
        -- Limit search depth to avoid performance issue
        local filtered_files = {}
        for _, file in ipairs(csproj_files) do
          local relative_path = file:sub(#cwd + 2)
          local depth = select(2, relative_path:gsub("/", ""))
          if depth <= 3 then
            table.insert(filtered_files, file)
          end
        end
        csproj_files = filtered_files
      end

      if #csproj_files == 0 then
        vim.notify("No .csproj file found in current directory or subdirectories", vim.log.levels.ERROR)
        -- Return a default path instead of nil to avoid DAP errors
        local fallback_path = vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
        return fallback_path ~= "" and fallback_path or (cwd .. "/bin/Debug/app.dll")
      end

      local csproj_file = csproj_files[1]
      local project_name = vim.fn.fnamemodify(csproj_file, ":t:r")
      local project_dir = vim.fn.fnamemodify(csproj_file, ":h")

      -- Notify if project was found in a subdirectory
      if project_dir ~= cwd then
        vim.notify("Found .NET project: " .. project_name .. "in" .. project_dir, vim.log.levels.INFO)
      end

      -- Read and parse .csproj file to get target frameword
      local csproj_content = vim.fn.readfile(csproj_file)
      local target_framework = nil

      for _, line in ipairs(csproj_content) do
        -- Look for TargetFramework (single) or TargetFrameworks (multiplw)
        local frameworks = line:match("<TargetFramework>([^<]+)</TargetFramework>")
        if frameworks then
          target_framework = frameworks:match("([^;]+)")
          break
        end
      end

      local possible_paths = {}

      if target_framework then
        -- Use the specific target framework from .csproj (use project directory, not cwd)
        table.insert(possible_paths, project_dir .. "/bin/Debug/" .. target_framework .. "/" .. project_name .. ".dll")
        table.insert(
          possible_paths,
          project_dir .. "/bin/Release/" .. target_framework .. "/" .. project_name .. ".dll"
        )
      end

      -- Fallback paths for legacy projects or if parsing failed (use project directory, not cwd)
      table.insert(possible_paths, project_dir .. "/bin/Debug/" .. project_name .. ".dll")
      table.insert(possible_paths, project_dir .. "/bin/Release/" .. project_name .. ".dll")

      for _, path in ipairs(possible_paths) do
        if vim.fn.filereadable(path) == 1 then
          return path
        end
      end

      -- If no DLL found, prompt user but with better default
      local default_path = target_framework and (project_dir .. "/bin/Debug/" .. target_framework .. "/")
        or (project_dir .. "/bin/Debug/")

      vim.notify("DLL not found, please build the project first with 'dotnet build'", vim.log.levels.WARN)
      local user_path = vim.fn.input("Path to dll: ", default_path, "file")

      -- Ensure we never return nil or empty string
      if user_path == "" then
        local fallback = target_framework
            and (project_dir .. "/bin/Debug/" .. target_framework .. "/" .. project_name .. ".dll")
          or (project_dir .. "/bin/Debug/" .. project_name .. ".dll")
        vim.notify("Using fallback path: " .. fallback, vim.log.levels.INFO)
        return fallback
      end

      return user_path
    end

    -- NET configuration
    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch .NET Core",
        request = "launch",
        program = get_dll_path,
      },
      {
        type = "coreclr",
        name = "Attach to process",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
    }

    -- Auto-open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
