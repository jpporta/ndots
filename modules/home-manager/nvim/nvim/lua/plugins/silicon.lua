return {
	"michaelrommel/nvim-silicon",
	lazy = true,
	cmd = "Silicon",
	config = function()
		local get_visual = function()
			local curpos = vim.fn.getcurpos()
			local one = { row = curpos[2] - 1, col = curpos[3] - 1 }
			local two = { row = vim.fn.line("v") - 1, col = vim.fn.col("v") - 1 }

			if one.row == two.row then
				if one.col > two.col then
					local tmp = one
					one = two
					two = tmp
				end
			elseif one.row > two.row then
				local tmp = one
				one = two
				two = tmp
			end

			two.col = two.col + 1
			return one.row
		end
		require("nvim-silicon").setup({
			font = "JetBrainsMono Nerd Font=24",
			no_window_controls = true,
			no_line_number = false,
			line_offset = get_visual() + 1,
			to_clipboard = true,
			window_title = function()
				return vim.fn.fnamemodify(vim.fn.bufname(vim.fn.bufnr()), ":~:.") .. " -  @jpporta"
			end,
			language = function()
				return vim.bo.filetype
			end,
		})
		vim.keymap.set("v", "<leader>cs", "<cmd>'<,'>Silicon<CR>", { desc = "[C]ode [S]elfie" })
	end,
}
