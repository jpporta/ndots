-- Seamless Ctrl+h/j/k/l navigation between Neovim splits and tuios panes, the
-- way vim-tmux-navigator does it for tmux. tuios cannot pass a key through
-- conditionally, so it leaves Ctrl+h/j/k/l to the pane and Neovim moves the
-- tuios focus itself when there is no split in that direction.
local directions = { h = "left", j = "down", k = "up", l = "right" }

for key, direction in pairs(directions) do
	vim.keymap.set("n", "<C-" .. key .. ">", function()
		local win = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(key)
		if win == vim.api.nvim_get_current_win() and vim.env.TUIOS_ENV == "1" then
			vim.system({ "tuios", "focus-window", "--direction", direction })
		end
	end, { desc = "Move to the " .. direction .. " split or tuios pane" })
end
