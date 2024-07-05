-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>a", "<cmd>w<CR><esc>", { desc = "Save File" })

vim.keymap.set("n", "<leader>rb", function()
  local file = vim.fn.expand("%:p")

  if vim.fn.executable("xdg-open") == 1 then
    vim.fn.jobstart({ "xdg-open", file })
  elseif vim.fn.executable("open") == 1 then
    vim.fn.jobstart({ "open", file })
  else
    print("No suitable command found to open the browser")
  end
end, { desc = "Run HTML in browser" })
