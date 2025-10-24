return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
  config = function()
    local function get_secret_path(secret_guid)
      local path = ""
      local home_dir = vim.fn.expand("~")
      if require("easy-dotnet.extensions").isWindows() then
        local secret_path = home_dir
          .. "\\AppData\\Roaming\\Microsoft\\UserSecrets\\"
          .. secret_guid
          .. "\\secrets.json"
        path = secret_path
      else
        local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
        path = secret_path
      end
      return path
    end

    local dotnet = require("easy-dotnet")
    dotnet.setup({
      lsp = {
        enabled = true,
        roslynator_enabled = true,
        analyser_assemblies = {},
        config = {},
      },
      new = {
        project = {
          prefix = "sln",
        },
      },
      secrets = {
        path = get_secret_path,
      },
      csproj_mappings = true,
      picker = "snacks",
    })
  end,
}
