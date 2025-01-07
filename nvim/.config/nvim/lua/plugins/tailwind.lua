return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  -- {
  --   "saghen/blink.cmp",
  --   dependencies = {
  --     { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
  --   },
  --   opts = function(_, opts)
  --     opts.formatting = {
  --       format = function(entry, item)
  --         return require("tailwindcss-colorizer-cmp").formatter(entry, item)
  --       end,
  --     }
  --     return opts
  --   end,
  -- },
}
