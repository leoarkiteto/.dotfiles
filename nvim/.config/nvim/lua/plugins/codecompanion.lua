return {
  "olimorris/codecompanion.nvim",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          opts = {
            stream = true,
          },
          env = {
            api_key = "",
          },
        })
      end,
      opts = {
        show_defaults = false,
      },
    },
    strategies = {
      chat = {
        adapter = "openai",
      },
      inline = {
        adapter = "openai",
      },
      cmd = {
        adapter = "openai",
      },
    },
    display = {
      action_pallete = {
        provider = "default",
      },
      chat = {
        icons = {
          tool_success = "v",
        },
      },
      diff = {
        provider = "gitsigns",
      },
    },
  },
}
