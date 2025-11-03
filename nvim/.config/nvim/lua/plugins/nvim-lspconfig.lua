return {
  -- Disable omnisharp LSP server
  -- Using easy-dotnet.nvim with csharp-ls instead
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = false, -- Explicity disable omnisharp
      },
      -- Prevent omnisharp from being auto-configured
      setup = {
        omnisharp = function()
          -- Return true to skip auto-setup and prevent LazyVim from configuring it
          return true
        end,
      },
    },
    init = function()
      -- Stop any already running omnisharp instances immediately
      vim.schedule(function()
        for _, client in ipairs(vim.lsp.get_clients()) do
          if client.name == "omnisharp" then
            vim.notify("Stopping omnisharp - using easy-dotnet.nvim with csharp-ls instead", vim.log.levels.INFO)
            vim.lsp.stop_client(client.id, true)
          end
        end
      end)

      -- Stop any new omnisharp instances that try to attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "omnisharp" then
            vim.notify("Stopping omnisharp - using easy-dotnet.nvim with csharp-ls instead", vim.log.levels.INFO)
            vim.lsp.stop_client(client.id, true)
          end
        end,
      })
    end,
  },
}
