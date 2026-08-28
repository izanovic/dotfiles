return {
  -- add Nord
  { "shaunsingh/nord.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "EdenEast/nightfox.nvim" },
  { "sainnhe/everforest" },
  { "JoosepAlviste/palenightfall.nvim" },
  { "rebelot/kanagawa.nvim" },

  -- Configure LazyVim to load Nord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
