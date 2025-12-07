-- LuaRocks plugin manager para dependencias Lua
-- Necessario para rest.nvim
return {
  "vhyrro/luarocks.nvim",
  priority = 1000, -- Carregar antes de outros plugins
  config = true,
  opts = {
    rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" },
  },
}
