-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set(
  "n",
  "<leader>fe",
  require("telescope.builtin").resume,
  { noremap = true, silent = true, desc = "Resume" }
)
vim.keymap.set("i", "jj", "<esc>", { noremap = true, silent = true })
vim.keymap.set("i", "hj", "<esc>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>y", function()
  local results = {
    vim.fn.expand("%:p"),
    vim.fn.expand("%:."),
    vim.fn.expand("%:~"),
    vim.fn.expand("%t"),
    vim.fn.expand("%:r"),
    vim.fn.expand("%:e"),
  }

  -- absolute path to clipboard
  local i = vim.fn.inputlist({
    "Choose to copy to clipboard:",
    "1. Absolute path: " .. results[1],
    "2. Path relative to CWD: " .. results[2],
    "3. Path relative to HOME: " .. results[3],
    "4. Filename: " .. results[4],
    "5. Filename without extension: " .. results[5],
    "6. Extension of the filename: " .. results[6],
  })

  if i > 0 then
    local result = results[i]
    if not result then
      return print("Invalid choice: " .. i)
    end
    vim.fn.setreg("*", result)
  end
end, { noremap = true, desc = "Copy file" })

vim.keymap.set(
  "n",
  "<leader>Ft",
  '<cmd>!tmux send-keys -t 2 C-z "cl; yarn test %:." Enter<CR>',
  { noremap = true, desc = "Test file" }
)

vim.keymap.set("n", "<leader>FT", function()
  if vim.bo.filetype == "php" then
    vim.cmd('!tmux send-keys -t 2 C-z "php artisan test %:." Enter<CR>')
  else
    vim.cmd('!tmux send-keys -t 2 C-z "yarn test %:." Enter<CR>')
  end
end, { noremap = true, desc = "Test file" })
-- = vim.fn.jobstart(
--     'echo ' + file,
--     {
--         cwd = '/path/to/working/dir',
--         on_exit = some_function,
--         on_stdout = some_other_function,
--         on_stderr = some_third_function
--     }
-- )
-- end, { noremap = true, desc = "Run test" })

vim.keymap.set("n", "<leader>;", "<cmd>EslintFixAll<CR>", { noremap = true, silent = true, desc = "Format eslint" })
-- harpoon
vim.keymap.set("n", "<leader>m", "<cmd>lua require('harpoon.mark').add_file()<cr>", { desc = "Add to Harpoon" })
vim.keymap.set("n", "<leader>0", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", { desc = "Show Harpoon" })
vim.keymap.set("n", "<leader>1", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", { desc = "Harpoon Buffer 1" })
vim.keymap.set("n", "<leader>2", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", { desc = "Harpoon Buffer 2" })
vim.keymap.set("n", "<leader>3", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", { desc = "Harpoon Buffer 3" })
vim.keymap.set("n", "<leader>4", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", { desc = "Harpoon Buffer 4" })
vim.keymap.set("n", "<leader>5", "<cmd>lua require('harpoon.ui').nav_file(5)<cr>", { desc = "Harpoon Buffer 5" })
vim.keymap.set("n", "<leader>6", "<cmd>lua require('harpoon.ui').nav_file(6)<cr>", { desc = "Harpoon Buffer 6" })
vim.keymap.set("n", "<leader>7", "<cmd>lua require('harpoon.ui').nav_file(7)<cr>", { desc = "Harpoon Buffer 7" })
vim.keymap.set("n", "<leader>8", "<cmd>lua require('harpoon.ui').nav_file(8)<cr>", { desc = "Harpoon Buffer 8" })
vim.keymap.set("n", "<leader>9", "<cmd>lua require('harpoon.ui').nav_file(9)<cr>", { desc = "Harpoon Buffer 9" })

-- vim.keymap.set(
--   "n",
--   "<leader>fv",
--   require("telescope.builtin").find_files({ search_file = ".vue" }),
--   { noremap = true, silent = true, desc = "Find vue files" }
-- )
--
-- vim.keymap.set(
--   "n",
--   "<leader>ft",
--   require("telescope.builtin").find_files({ search_file = ".ts" }),
--   { noremap = true, silent = true, desc = "Find ts files" }
-- )
--
-- vim.keymap.set(
--   "n",
--   "<leader>fh",
--   require("telescope.builtin").find_files({ hidden = true }),
--   { noremap = true, silent = true, desc = "Find hidden files" }
-- )
--
