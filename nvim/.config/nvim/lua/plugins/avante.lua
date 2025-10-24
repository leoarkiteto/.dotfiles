return {
  "yetone/avante.nvim",
  opts = {
    provider = "openai",
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-41",
        timeout = 30000,
        context_window = 128000,
        api_key_name = "OPENAI_API_KEY", -- Explicitly specify the environment variable name
        extra_request_body = {
          temperature = 0,
        },
      },
    },
    behaviour = {
      auto_apply_diff_after_generation = true,
    },
    web_search_engine = {
      provider = "tavily",
      proxy = nil,
      providers = {
        tavily = {
          api_key_name = "TAVILY_API_KEY",
          extra_request_body = {
            include_answer = "basic",
          },
        },
      },
    },
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ""
    end,
    -- Using function prevents requiring mcphub before it's loaded
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
  },
}
