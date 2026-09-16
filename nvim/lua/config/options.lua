-- Core Neovim editor options
-- Architecture: Native configuration layer prior to any plugin loader

local opt = vim.opt

-- Line numbering (relative for fast motions)
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation (Python default: 4 spaces)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Line wrapping
opt.wrap = false

-- Search behavior
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Visual & Appearance
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Clipboard & Mouse
opt.clipboard = "unnamedplus" -- sync with OS clipboard
opt.mouse = "a"

-- Split behaviors
opt.splitbelow = true
opt.splitright = true

-- File management & backup
opt.swapfile = false
opt.backup = false
opt.undofile = true -- persistent undo across sessions

-- Performance & Responsiveness
opt.updatetime = 250 -- faster completion and diagnostic trigger
opt.timeoutlen = 300 -- faster keymap sequence evaluation
