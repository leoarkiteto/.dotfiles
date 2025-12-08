-- GDScript LSP configuration for Godot Engine
-- This configuration does NOT use nvim-lspconfig's config function
-- to avoid interfering with LazyVim's default LSP keymaps

return {
  {
    "nvim-lspconfig",
    opts = function(_, opts)
      -- Add godot LSP server configuration
      opts.servers = opts.servers or {}
      opts.servers.gdscript = {
        -- Use manual setup via autocmd instead
        manual_setup = true,
      }
      return opts
    end,
  },
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
  -- Setup GDScript LSP connection without interfering with lspconfig
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Function to start GDScript LSP
      local function start_gdscript_lsp()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Check if LSP is already running
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "godot" })
        if #clients > 0 then
          vim.notify("GDScript LSP already connected", vim.log.levels.INFO)
          return
        end

        -- Find project root
        local root_dir = vim.fs.find({ "project.godot" }, {
          upward = true,
          path = vim.api.nvim_buf_get_name(bufnr),
        })[1]

        if root_dir then
          root_dir = vim.fs.dirname(root_dir)
        else
          root_dir = vim.fn.getcwd()
        end

        -- Start LSP client
        vim.lsp.start({
          name = "godot",
          cmd = { "/usr/bin/nc", "127.0.0.1", "6005" },
          root_dir = root_dir,
          on_attach = function(client, buf)
            vim.notify("✅ GDScript LSP connected to Godot Editor", vim.log.levels.INFO)
            -- LazyVim's LSP keymaps are automatically applied via LspAttach event
          end,
        })
      end

      -- Create user command
      vim.api.nvim_create_user_command("GodotLSP", start_gdscript_lsp, { desc = "Connect to Godot LSP server" })

      -- Auto-start GDScript LSP when opening .gd files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gdscript",
        callback = start_gdscript_lsp,
        desc = "Auto-start GDScript LSP for Godot files",
      })
    end,
  },
}
