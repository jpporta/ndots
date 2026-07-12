vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stayle release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.language = "en_US"

require("lazy").setup("plugins")
require("jpporta.autocommands")
require("jpporta.remaps")
require("jpporta.sets")
require("jpporta.lsp")
require("jpporta.theme")
require("jpporta.snippets")
require("jpporta.macros")
