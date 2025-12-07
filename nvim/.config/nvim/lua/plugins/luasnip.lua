return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local luasnip = require("luasnip")

    -- Configuration options
    luasnip.config.setup({
      -- Enable autotriggered snippets
      enable_autosnippets = true,
      -- Use Tab (or some other key if you prefer) to trigger visual selection
      store_selection_keys = "<Tab>",
      -- Event on which to check for exiting a snippet's region
      region_check_events = "CursorMoved,CursorHold,InsertEnter",
      delete_check_events = "TextChanged,InsertLeave",
    })

    -- Load snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Load custom snippets from snippets directory (works with GNU Stow)
    local snippets_path = vim.fn.stdpath("config") .. "/snippets"
    require("luasnip.loaders.from_vscode").load({
      paths = { snippets_path },
    })
    
    -- Debug: Check if snippets loaded
    vim.defer_fn(function()
      local snippets = luasnip.get_snippets("gdscript")
      if snippets and #snippets > 0 then
        vim.notify(string.format("✅ Loaded %d GDScript snippets", #snippets), vim.log.levels.INFO)
      else
        vim.notify("⚠️  No GDScript snippets loaded!", vim.log.levels.WARN)
      end
    end, 1000)

    -- Load SnipMate-style snippets (optional)
    require("luasnip.loaders.from_snipmate").lazy_load()

    -- Load Lua snippets (optional)
    require("luasnip.loaders.from_lua").lazy_load()

    -- Key mappings for snippet navigation
    vim.keymap.set({ "i" }, "<C-K>", function()
      luasnip.expand()
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-L>", function()
      luasnip.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-J>", function()
      luasnip.jump(-1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-E>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end, { silent = true })

    -- Command to list all available snippets from current filetype
    vim.api.nvim_create_user_command("ListSnippets", function()
      local ft = vim.bo.filetype or "all"
      local snippets = luasnip.get_snippets(ft)

      if not snippets or #snippets == 0 then
        print("No snippets available for filetype: " .. ft)
        return
      end

      print(string.format("Available snippets for '%s':\n", ft))
      for _, snippet in ipairs(snippets) do
        local trigger = snippet.trigger or snippet.dTrig or "<unknown>"
        local desc = snippet.dscr or snippet.description or ""
        print(string.format("  %-20s %s", trigger, desc))
      end
    end, { desc = "List all available snippets for current filetype" })
    
    -- Command to reload snippets
    vim.api.nvim_create_user_command("ReloadSnippets", function()
      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      require("luasnip.loaders.from_vscode").load({
        paths = { snippets_path },
      })
      vim.notify("✅ Snippets reloaded!", vim.log.levels.INFO)
    end, { desc = "Reload custom snippets" })
  end,
}
