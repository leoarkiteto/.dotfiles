return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "saghen/blink.compat",
      "rafamadriz/friendly-snippets",
    },
    opts = {
      snippets = { preset = "default" },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      sources = {
        default = {
          "lsp",
          "snippets",
          "path",
          "buffer",
          "dadbod",
          "avante_commands",
          "avante_mentions",
        },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
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
  },
}
