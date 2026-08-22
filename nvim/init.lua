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
vim.opt.laststatus = 0

require("lazy").setup({
  { "RRethy/base16-nvim" },
})

local function apply_custom_highlights()
  local ok, base16 = pcall(require, 'base16-colorscheme')
  if not (ok and base16.colorscheme) then return end
  local c = base16.colorscheme

  local groups = {
    Comment              = { fg = c.base05, italic = true, blend = 40 },
    ["@comment"]          = { fg = c.base05, italic = true, blend = 40 },
    ["@punctuation.special"] = { fg = c.base0D, bold = true },
    ["@punctuation.bracket"] = { fg = c.base0D },
    ["@string"]           = { fg = c.base0B },
    StatusLine            = { fg = c.base05, bg = c.base01 },
    StatusLineNC          = { fg = c.base03, bg = c.base00 },
  }

  for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

require('matugen').setup()
apply_custom_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = apply_custom_highlights,
})

local signal = vim.uv.new_signal()
signal:start('sigusr1', vim.schedule_wrap(function()
  apply_custom_highlights()
end))
