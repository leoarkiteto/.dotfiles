-- ===============================================================================
-- Tailwind CSS Configuration
-- Comprehensive Tailwind development experience with colorization and tools
-- LazyVim Compatible
-- ===============================================================================

return {
  -- ===============================================================================
  --  Color Hightlighting & Visualization
  -- ===============================================================================
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes = {
        "css",
        "scss",
        "sass",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
        "tsx",
        "jsx",
      },
      user_default_options = {
        RBG = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS features: rgb_fn, hsl_fn
        -- Tailwind specific
        tailwind = true, -- Enable tailwind colors
        sass = { enable = true, parsers = { "css" } }, -- Enalbe sass colors
        mode = "virtualtext", -- Display mode: 'foreground', 'background', 'virtualtext'
        virtualtext = "󰝤", -- Character to use for virtualtext
        always_update = false, -- Update color values even if buffer not focused
      },
      buftypes = {},
    },
  },

  -- ===============================================================================
  --  Tailwind Class Sorting & Organization
  -- ===============================================================================
  {
    "laytan/tailwind-sorter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    cmd = { "TailwindSort", "TailwindSortOnSaveToggle" },
    keys = {
      { "<leader>cT", "<cmd>TailwindSort<cr>", desc = "Sort Tailwind classes" },
    },
    build = "cd formatter && npm i && npm run build",
    config = function()
      require("tailwind-sorter").setup({
        on_save_enabled = true,
        on_save_pattern = {
          "*.html",
          "*.js",
          "*.jsx",
          "*.ts",
          "*.tsx",
          "*.vue",
          "*.svelte",
          "*.astro",
        },
        node_path = "node",
      })
    end,
  },

  -- ===============================================================================
  --  Tailwind CSS IntelliSense Enhancement
  -- ===============================================================================
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    ft = {
      "html",
      "css",
      "scss",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "svelte",
      "astro",
    },
    keys = {
      { "<leader>TS", "<cmd>TailwindSort<cr>", desc = "Sort Tailwind classes" },
    },
    opts = {
      document_color = {
        enabled = true, -- Can be toggled by commands
        kind = "inline", -- 'inline' | 'foreground' | 'background'
        inline_symbol = "", -- Only used in inline mode
        debounce = 200, -- In milliseconds, only applied in insert mode
      },
      conceal = {
        enabled = false, -- Can be toggled by commands
        min_length = nil, -- Only ocnceal classes longer than this length
        symbol = "󱏿", -- Only a single character is allowed
        highlight = { --Extmark highlight options, see :h 'highlight'
          fg = "#38bdf8",
        },
      },
      custom_filetypes = {}, -- See the extensions section to learn how it works
    },
  },
}
