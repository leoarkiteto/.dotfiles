return {
  "elvxk/mylorem.nvim",
  event = "InsertEnter",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
  config = function()
    require("mylorem").setup({
      luasnip = true, -- Enable for LuaSnip
      ultisnips = false, -- Deisable UltSnips
      vsnip = false, -- Disbale VSnip
      default = true, -- Use LuaSnip by default
    })
  end,
}
