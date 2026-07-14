local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
local ret = vim.api.nvim_replace_termcodes("<CR>", true, true, true)

vim.keymap.set("n", "<leader>op", function()
	vim.api.nvim_feedkeys(esc .. "o" .. os.date("%H:%M", os.time()) .. ": ", "n", true)
end, { expr = true, desc = "New atomic journal" })

vim.keymap.set("i", "<C-p>", function()
	vim.api.nvim_feedkeys(os.date("%H:%M", os.time()) .. ": ", "i", true)
end, { desc = "New atomic journal inline" })
