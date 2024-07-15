return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      mode = { "n", "v" },
      ["<leader>p"] = { name = "+database" },
      ["<leader>r"] = { name = "+live-server" },
      ["<leader>h"] = { name = "+request" },
    },
  },
}
