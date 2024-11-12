return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          "filename",
          file_status = true,
          newfile_status = false,
          path = 1,
          shorting_target = 40,
          symbols = {
            modified = "󰠘", -- Text to show when the file is modified.
            readonly = "󰍁", -- Text to show when the file is non-modifiable or readonly.
            unnamed = "[No Name]", -- Text to show for unnamed buffers.
            newfile = "", -- Text to show for newly created file before first write
          },
        },
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
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
