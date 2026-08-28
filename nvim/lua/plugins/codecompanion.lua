return {
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      -- Inline assistant (visual mode)
      {
        "<leader>ai",
        ":CodeCompanion<CR>",
        mode = "v",
        desc = "AI: Inline Assistant",
      },
      -- Open chat window
      {
        "<leader>ac",
        ":CodeCompanionChat<CR>",
        desc = "AI: Chat",
      },
      -- Open action palette
      {
        "<leader>aa",
        ":CodeCompanionActions<CR>",
        desc = "AI: Actions",
      },
      -- Run shell command prompt
      {
        "<leader>as",
        ":CodeCompanionCmd<CR>",
        desc = "AI: Shell Command",
      },
      -- Re-run last action
      {
        "<leader>ar",
        function()
          require("codecompanion").actions.run_last()
        end,
        desc = "AI: Re-run Last Action",
      },
      -- Suggest code edit (optional)
      {
        "<leader>ae",
        function()
          require("codecompanion.inline").suggest_code_edit()
        end,
        desc = "AI: Suggest Code Edit",
      },
      -- Summarize current file (optional)
      {
        "<leader>af",
        function()
          vim.cmd("CodeCompanion #file")
        end,
        desc = "AI: Summarize File",
      },
    },
  },
}
