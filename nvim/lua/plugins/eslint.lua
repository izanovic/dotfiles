return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").on_attach(function(_, buffer)
          -- vim.api.nvim_create_autocmd("BufWritePre", {
          --   buffer = bufnr,
          --   pattern = { "*.vue", "*.ts", "*.js" },
          --   command = "EslintFixAll",
          -- })
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    opt = {
      autoformat = false,
    },
  },
}
