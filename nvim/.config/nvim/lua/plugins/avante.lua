return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  enabled = false,
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "saghen/blink.cmp",
    "nvim-mini/mini.icons",
    "folke/snacks.nvim",
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
  opts = {
    mode = "legacy",
    provider = "openai",
    behaviour = {
      auto_apply_diff_after_generation = true,
      support_paste_from_clipboard = true,
    },
    mappings = {
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },
    windows = {
      --- @type 'right' | 'left' |'top'|'bottom'
      position = "right",
      wrap = true,
      width = 30,
      sidebar_header = {
        align = "center",
        rounded = true,
      },
      input = {
        prefix = "> ",
        height = 8,
      },
      edit = {
        border = "rounded",
        start_insert = true,
      },
      ask = {
        floating = false,
        start_insert = true,
        border = "rounded",
        ---@type 'ours' | 'theirs'
        focus_on_apply = "ours",
      },
    },
    highlights = {
      ---@class AvanteConflictHightlights
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
    ---@class AvanteConflictUserConfig
    diff = {
      autojump = true,
      ---@type string | fun(): string
      list_opener = "copen",
    },
    ---@class AvanteInputProviderConfig
    input = {
      provider = "snacks",
    },
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        timeout = 30000,
        max_tokens = 4096,
        ["local"] = false,
        api_key_name = "OPENAI_API_KEY", -- Explicitly specify the environment variable name
        extra_request_body = {
          temperature = 0,
        },
      },
    },
  },
}
