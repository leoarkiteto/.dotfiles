return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "saghen/blink.compat",
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip",
      "nvim-mini/mini.icons",
    },
    specs = { "Kaiser-Yang/blink-cmp-avante" },
    opts = {
      snippets = { preset = "luasnip" },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      sources = {
        default = {
          "lsp",
          "snippets",
          "path",
          "buffer",
          "dadbod",
          "easy-dotnet",
        },
        providers = {
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
          ["easy-dotnet"] = {
            name = "easy-dotnet",
            module = "easy-dotnet.completion.blink",
            score_offset = 10000,
            async = true,
          },
        },
      },
      completion = {
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local ok, mini_icons = pcall(require, "mini.icons")
                    if ok and mini_icons and mini_icons.get_icon then
                      local mini_icon, _ = mini_icons.get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then
                        return mini_icon .. ctx.icon_gap
                      end
                    end
                  end

                  local icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from mini.icons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local ok, mini_icons = pcall(require, "mini.icons")
                    if ok and mini_icons and mini_icons.get_icon then
                      local mini_icon, mini_hl = mini_icons.get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then
                        return mini_hl
                      end
                    end
                  end
                  return ctx.kind_hl
                end,
              },
              kind = {
                -- Optional, use highlights from mini.icons
                highlight = function(ctx)
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local ok, mini_icons = pcall(require, "mini.icons")
                    if ok and mini_icons and mini_icons.get_icon then
                      local mini_icon, mini_hl = mini_icons.get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then
                        return mini_hl
                      end
                    end
                  end
                  return ctx.kind_hl
                end,
              },
            },
          },
        },
      },
      keymap = {
        preset = "enter",
        ["<S-Tab>"] = { "select_prev" },
        ["<Tab>"] = { "select_next" },
      },
    },
  },
}
