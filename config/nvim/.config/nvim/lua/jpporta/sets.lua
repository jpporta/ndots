vim.opt.guicursor = ""
vim.opt.relativenumber = true
vim.o.hlsearch = false
vim.wo.number = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.tabstop = 2
vim.o.shiftwidth = 4
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.opt.scrolloff = 8
vim.o.completeopt = "menuone,noselect"
vim.o.termguicolors = true
vim.o.swapfile = false
vim.o.cursorline = true
vim.cmd.set("cursorline")
vim.cmd.set("cursorcolumn")
vim.opt.conceallevel = 2
vim.opt.colorcolumn = "80"
vim.api.nvim_create_user_command("CpFullPath", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command("CpRelPath", function()
	local path = vim.fn.expand("%")
	vim.fn.setreg("+", path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.g.neoformat_try_node_exe = 1
vim.opt.winborder = 'rounded'
