return {
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
