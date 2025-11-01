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

    -- Fix for easy-dotnet.nvim bug where proc source options are incorrectly constructed
    -- The but is in easy-dotnet.nvim's _snacks.lua where it does {opts, {cmd = ...}}
    -- instead of properly merging the tables, This cause "opts.cmd is required" error.
    local ok, snacks_module = pcall(require, "easy-dotnet.picker._snacks")
    if ok and snacks_module and snacks_module.nuget_search then
      local snack_picker = require("snacks")
      local proc_source = require("snacks.picker.source.proc")

      -- Replace nuget_search with a fixed version that properly merges proc options
      snacks_module.nuget_search = function()
        local selected = nil
        local co = coroutine.running()

        local function find_nuget_packages(opts, ctx)
          local args = {
            "package",
            "search",
            ctx.filter.search or "",
            "--format",
            "json",
          }
          -- Fix properly merge opts instead of creating nested table {opts, {cmd = ...}}
          local proc_opts = vim.tbl_extend("force", opts or {}, {
            cmd = "dotnet",
            args = args,
            transform = function(item)
              if item.text:match('"id":') then
                return { text = item.text:match('"id":%s*"([^"]+)"') }
              else
                return false
              end
            end,
          })
          return proc_source.proc(proc_opts, ctx)
        end

        snack_picker.picker.pick(nil, {
          title = "Nuget Search",
          live = true,
          layout = "select",
          format = "text",
          finder = find_nuget_packages,
          confirm = function(picker, item)
            picker:close()
            selected = item.text
            if coroutine.status(co) ~= "running" then
              coroutine.resume(co)
            end
          end,
        })

        if not selected then
          coroutine.yield()
        end
        return selected
      end
    end
  end,
}
