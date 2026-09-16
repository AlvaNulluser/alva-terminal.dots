-- Core Neovim autocommands
-- Architecture: Native event-driven lifecycle actions using vim.api

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight text on yank (visual feedback)
local yank_group = augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 150,
    })
  end,
  desc = "Flash visual highlight when copying text",
})

-- Prevent automatic comment insertion on new lines (Enter or 'o')
local comment_group = augroup("DisableAutoComment", { clear = true })
autocmd("FileType", {
  group = comment_group,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable automatic comment continuation on new line",
})

-- Filetype-specific indentation (2 spaces for Web/Configs, 4 for Python)
local indent_group = augroup("FileTypeIndent", { clear = true })
autocmd("FileType", {
  group = indent_group,
  pattern = {
    "html",
    "css",
    "scss",
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "json",
    "yaml",
    "lua",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "Set 2-space indentation for web and config formats",
})

autocmd("FileType", {
  group = indent_group,
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
  desc = "Set 4-space indentation for Python",
})

-- Restore cursor to last known position when reopening a file
local last_pos_group = augroup("LastCursorPosition", { clear = true })
autocmd("BufReadPost", {
  group = last_pos_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor to last known location in file",
})
