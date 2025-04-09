return {
  "jghauser/fold-cycle.nvim",
  event = "BufReadPost",
  opts = {
    open_if_max_closed = true,
    close_if_max_opened = true,
    soft_wrap_movement_fit = true,
  },
  keys = {
    {
      "zo",
      function()
        require("fold-cycle").open()
      end,
      desc = "Fold-cycle open",
    },
    {
      "zc",
      function()
        require("fold-cycle").close()
      end,
      desc = "Fold-cycle close",
    },
    {
      "za",
      function()
        require("fold-cycle").toggle_all()
      end,
      desc = "Fold-cycle toggle all",
    },
    {
      "zM",
      function()
        require("fold-cycle").close_all()
      end,
      desc = "Fold-cycle close all",
    },
    {
      "zR",
      function()
        require("fold-cycle").open_all()
      end,
      desc = "Fold-cycle open all",
    },
  },
}
