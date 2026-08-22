-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.laststatus = 3

require("lazy").setup({
  { "RRethy/base16-nvim" },
})

local function apply_custom_highlights()
  local ok, base16 = pcall(require, 'base16-colorscheme')
  if ok and base16.colorscheme then
    local c = base16.colorscheme
    vim.api.nvim_set_hl(0, 'Comment', { fg = c.base04, italic = true })
    vim.api.nvim_set_hl(0, '@comment', { fg = c.base04, italic = true })
    vim.api.nvim_set_hl(0, '@punctuation.special', { fg = c.base09 })
    vim.api.nvim_set_hl(0, '@string', { fg = c.base0B })
    vim.api.nvim_set_hl(0, 'StatusLine', { fg = c.base05, bg = c.base01 })
    vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = c.base03, bg = c.base00 })
  end
end

require('matugen').setup()
apply_custom_highlights()

local signal = vim.uv.new_signal()
signal:start('sigusr1', vim.schedule_wrap(function()
  apply_custom_highlights()
end))
