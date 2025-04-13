return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  init = function()
    -- Hack for https://github.com/yetone/avante.nvim/issues/1759
    local chdir = vim.api.nvim_create_augroup("chdir", {})
    vim.api.nvim_create_autocmd("BufEnter", {
      group = chdir,
      nested = true,
      callback = function()
        vim.go.autochdir = not vim.bo.filetype:match("^Avante")
      end,
    })
  end,
  opts = {
    provider = "ollama",
    cursor_applying_provider = "ollama",
    ollama = {
      endpoint = "http://127.0.0.1:11434",
      model = "codellama", -- your desired model (or use gpt-4o, etc.)
      timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
      opts = {
        temperature = 0,
        num_ctx = 20480,
      },
    },
    behavior = {
      enable_cursor_planning_mode = true,
      aplly_to_current_buffer = true,
      buffer_options = {
        apply_to_current = true,
      },
    },
    file_selector = {
      provider = "snacks",
    },
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "saghen/blink.cmp",
    "echasnovski/mini.icons",
    "folke/snacks.nvim",
    "Kaiser-Yang/blink-cmp-avante",
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
