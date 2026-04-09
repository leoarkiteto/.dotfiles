return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- Configuração do adapter Ollama
    adapters = {
      ollama = {
        endpoint = "http://localhost:11434",
        model = "deepseek-coder",
        temperature = 0.1,
      },
    },

    -- Estratégias padrão
    strategies = {
      chat = {
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
      agent = {
        adapter = "ollama",
      },
    },
  },
}
