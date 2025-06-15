-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set = vim.keymap.set
set("n", "cw", "ciw", { noremap = true, silent = true })
-- Map Ctrl + Shift + V to enter Visual Block Mode
set("n", "<C-S-v>", "<C-V>", { noremap = true, silent = true })
-- Easy copy and pasting full files
set("n", "<Space>C", "ggVGy+", { noremap = true, silent = true })
set("n", "<Space>p", "ggVGp", { noremap = true, silent = true })
set("n", "<Space>P", "ggVGP", { noremap = true, silent = true })
-- Map Space + Q to write all files and quit Neovim
set("n", "<Space>q", ":wqall<CR>", { noremap = true, silent = true })
set("n", "<leader>cd", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #diagnostics == 0 then
    print("No diagnostics under cursor")
    return
  end
  local msg = diagnostics[1].message
  vim.fn.setreg("+", msg) -- Copy to system clipboard
  -- Show diagnostics float
  vim.diagnostic.open_float()
end, { desc = "Copy diagnostic under cursor and show it" })
-- Console.log the variable under the cursor
set("n", "<leader>cL", function()
  local word = vim.fn.expand("<cword>")
  local log = string.format("console.log('%s', %s);", word, word)
  vim.api.nvim_put({ log }, "l", true, true)
  vim.cmd("normal! k==")
end, { desc = "Console log word under cursor" })

-- Characters you want to map as text objects
local textobjects = { "`", "'", '"', "[", "]", "{", "}", "(", ")", "<", ">", "q" }

-- Map each character to its inner text object in visual and operator-pending modes
for _, char in ipairs(textobjects) do
  set({ "o", "x" }, char, "i" .. char, { remap = true })
end
