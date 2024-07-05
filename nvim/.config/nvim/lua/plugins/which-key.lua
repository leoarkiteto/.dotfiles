return {
  "folke/which-key.nvim",
  opts = {
    defaults = {
      mode = { "n", "v" },
      ["<leader>p"] = { name = "+database" },
      ["<leader>r"] = { name = "+live-server" },
      ["<leader>h"] = { name = "+request" },
    },
  },
}
