-- Python Virtual Environment Selector
-- Automatically detect and switch local .venv, Poetry, and Conda environments

return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp", -- modern regexp branch supports Neovim 0.10+ and 0.12+
    cmd = "VenvSelect",
    ft = "python",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Python VirtualEnv", ft = "python" },
    },
  },
}
