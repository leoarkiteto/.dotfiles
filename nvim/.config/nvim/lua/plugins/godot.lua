return {
  -- vim-godot plugin for Godot integration
  {
    "habamax/vim-godot",
    ft = { "gdscript", "gd" },
    config = function()
      -- Configure Godot executable path
      -- Default to 'godot' in PATH, but can be customized
      -- Example: vim.g.godot_executable = '/Applications/Godot.app/Contents/MacOS/Godot'
      vim.g.godot_executable = vim.g.godot_executable or "godot"

      -- Auto-detect Godot executable on macOS
      if vim.fn.has("macunix") == 1 then
        local common_path = {
          "/Applications/Godot.app/Contents/MacOS/Godot",
          "/Applications/Godot_mono.app/Contents/MacOS/Godot",
          vim.fn.expand("~/Applications/Godot.app/Contents/MacOS/Godot"),
        }
        for _, path in ipairs(common_path) do
          if vim.fn.executable(path) == 1 then
            vim.g.godot_executable = path
            break
          end
        end
      end

      -- Set up GDScript file-specific settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "gdscript", "gd" },
        callback = function()
          -- GDScript uses tabs, no spaces
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
          vim.bo.expandtab = false -- Use tabs, not spaces
          vim.bo.commentstring = "# %s" -- GDScript uses # for comments

          -- Enable auto-indentation
          vim.bo.autoindent = true
          vim.bo.smartindent = true

          -- Set text width (optional, GDScript doesn't have strict line lenght)
          vim.bo.textwidth = 80
        end,
        desc = "Configure GDScript file settings",
      })
    end,
  },
}
