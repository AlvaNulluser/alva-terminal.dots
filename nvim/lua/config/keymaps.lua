-- Core Neovim keymaps
-- Architecture: Ergonomic keybindings using native vim.keymap APIs

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }


-- Clear search highlight on pressing <Esc> in normal mode
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Fast saving and quitting
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file", silent = true })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window", silent = true })

-- Move selected lines up/down in Visual mode (re-indents automatically)
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down", silent = true })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up", silent = true })

-- Keep cursor centered during half-page scrolling and search jumping
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Window navigation (splits)
keymap("n", "<C-h>", "<C-w>h", { desc = "Navigate window left", silent = true })
keymap("n", "<C-j>", "<C-w>j", { desc = "Navigate window down", silent = true })
keymap("n", "<C-k>", "<C-w>k", { desc = "Navigate window up", silent = true })
keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate window right", silent = true })

-- Window splitting
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertically", silent = true })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally", silent = true })
keymap("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size", silent = true })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split", silent = true })

-- Buffer navigation
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer", silent = true })

-- Paste over selected text in visual mode without overwriting the default register
keymap("x", "<leader>p", [["_dP]], { desc = "Paste without replacing register", silent = true })
