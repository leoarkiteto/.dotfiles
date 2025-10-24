return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
    },
    sections = {
      lualine_a = { "mode", require("easy-dotnet.ui-modules.jobs").lualine },
      lualine_b = {
        "branch",
        {
          "diff",
          source = function()
            local summary = vim.b.minidiff_summary
            return summary
              and {
                added = summary.add,
                modified = summary.change,
                removed = summary.delete,
              }
          end,
        },
        "diagnostics",
      },
      lualine_c = {
        {
          "filename",
          file_status = true,
          newfile_status = false,
          path = 1,
          shorting_target = 40,
          symbols = {
            modified = "", -- Text to show when the file is modified.
            readonly = "", -- Text to show when the file is non-modifiable or readonly.
            unnamed = "[No Name]", -- Text to show for unnamed buffers.
            newfile = "", -- Text to show for newly created file before first write
          },
        },
      },
      lualine_x = {
        {
          function()
            -- Check if MCPHub is loaded
            if not vim.g.loaded_mcphub then
              return "󰐻 -"
            end

            local count = vim.g.mcphub_servers_count or 0
            local status = vim.g.mcphub_status or "stopped"
            local executing = vim.g.mcphub_executing

            -- Show "-" when stopped
            if status == "stopped" then
              return "󰐻 -"
            end

            -- Show spinner when executing, starting, or restarting
            if executing or status == "starting" or status == "restarting" then
              local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
              local frame = math.floor(vim.loop.now() / 100) % #frames + 1
              return "󰐻 " .. frames[frame]
            end

            return "󰐻 " .. count
          end,
          color = function()
            if not vim.g.loaded_mcphub then
              return { fg = "#6c7086" } -- Gray for not loaded
            end

            local status = vim.g.mcphub_status or "stopped"
            if status == "ready" or status == "restarted" then
              return { fg = "#50fa7b" } -- Green for connected
            elseif status == "starting" or status == "restarting" then
              return { fg = "#ffb86c" } -- Orange for connecting
            else
              return { fg = "#ff5555" } -- Red for error/stopped
            end
          end,
        },
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
