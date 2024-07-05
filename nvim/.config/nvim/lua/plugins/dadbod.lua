return {
  "tpope/vim-dadbod",
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  opts = {
    db_completion = function()
      require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
    end,
  },
  config = function(_, opts)
    vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function()
        vim.schedule(opts.db_completion)
      end,
    })
  end,
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  keys = {
    {
      "<leader>pd",
      "<cmd>DBUIToggle<CR>",
      desc = "Toggle DB UI",
    },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
