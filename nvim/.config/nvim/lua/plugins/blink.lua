return {
  "saghen/blink.cmp",
  opts = {
    fuzzy = { implementation = "prefer_rust_with_warning" },
    sources = {
      default = { "lsp", "snippets", "path", "buffer", "easy-dotnet" },
      providers = {
        ["easy-dotnet"] = {
          name = "easy-dotnet",
          enabled = true,
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
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
            kind = {
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
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
}
