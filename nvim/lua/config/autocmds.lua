-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*tmux.conf" },
    command = "execute 'silent !tmux source <afile> --silent'",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "vue", "spec.ts", "ts", "js", "php" },
    callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
})
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--     pattern = { "vue", "ts", "js" },
--     callback = function()
--         vim.b.autoformat = false
--     end,
-- })
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   callback = function()
--     vim.cmd("EslintFixAll")
--   end,
-- })
