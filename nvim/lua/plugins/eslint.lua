return {
    "neovim/nvim-lspconfig",
    -- other settings removed for brevity
    opts = {
        ---@type lspconfig.options
        servers = {
            eslint = {
                settings = {
                    -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
                    workingDirectory = { mode = "auto" },
                },
            },
        },
        setup = {
            eslint = function()
                require("lazyvim.util").lsp.on_attach(function(client)
                    if client.name == "eslint" then
                        client.server_capabilities.documentFormattingProvider = true
                    elseif client.name == "tsserver" then
                        client.server_capabilities.documentFormattingProvider = false
                    end
                end)
            end,
        },
    },
}
-- return {
--     {
--         "neovim/nvim-lspconfig",
--         dependencies = {
--             "jose-elias-alvarez/typescript.nvim",
--             init = function()
--                 require("lazyvim.util").lsp.on_attach(function(_, buffer)
--             -- vim.api.nvim_create_autocmd("BufWritePre", {
--             --   buffer = bufnr,
--             --   pattern = { "*.vue", "*.ts", "*.js" },
--             --   command = "EslintFixAll",
--             -- })
--             -- stylua: ignore
--             vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
--                     vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
--                 end)
--             end,
--         },
--         opt = {
--             servers = { eslint = {} },
--             setup = {
--                 eslint = function()
--                     require("lazyvim.util").lsp.on_attach(function(client)
--                         if client.name == "eslint" then
--                             client.server_capabilities.documentFormattingProvider = true
--                         elseif client.name == "tsserver" then
--                             client.server_capabilities.documentFormattingProvider = false
--                         end
--                     end)
--                 end,
--             },
--         },
--     },
-- }
