-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true

-- Custom colorscheme
vim.cmd("highlight clear")
vim.opt.background = "dark"

local hl = vim.api.nvim_set_hl
hl(0, "Normal", { fg = "#e0e0e0", bg = "#1a1a1a" })
hl(0, "Comment", { fg = "#808080", italic = true })
hl(0, "String", { fg = "#ffc87f" })
hl(0, "Number", { fg = "#7fc8ff" })
hl(0, "Function", { fg = "#c7ff7f" })
hl(0, "Keyword", { fg = "#ff9e7d" })
hl(0, "Type", { fg = "#7fc8ff" })
hl(0, "Identifier", { fg = "#e0e0e0" })
hl(0, "Statement", { fg = "#ff9e7d" })
hl(0, "LineNr", { fg = "#555555" })
hl(0, "CursorLineNr", { fg = "#ffc87f" })
hl(0, "Visual", { bg = "#3a3a3a" })
hl(0, "Search", { bg = "#555555", fg = "#ffff99" })
