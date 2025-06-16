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

local function toggle_neotree_side(side)
  -- Close the opposite side if it's open
  local opposite = side == "left" and "right" or "left"
  vim.cmd("Neotree close position=" .. opposite)

  -- Toggle the requested side
  vim.cmd("Neotree toggle position=" .. side)
end

vim.keymap.set("n", "<leader>e", function()
  toggle_neotree_side("left")
end, { desc = "Neo-tree (left side)" })

vim.keymap.set("n", "<leader>ue", function()
  toggle_neotree_side("right")
end, { desc = "Neo-tree (right side)" })
