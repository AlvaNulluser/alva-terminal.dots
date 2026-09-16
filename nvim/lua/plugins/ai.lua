-- AI inline completion
-- Supermaven integration with free tier and low latency

return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<C-j>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-l>",
      },
      ignore_filetypes = {
        "TelescopePrompt",
        "snacks_picker_input",
        "oil",
        "neo-tree",
      },
      color = {
        suggestion_color = "#6c7086", -- Catppuccin Overlay0 subtle gray
        cterm = 244,
      },
      disable_inline_completion = false,
      disable_keymaps = false,
      log_level = "warn",
    },
  },
}
