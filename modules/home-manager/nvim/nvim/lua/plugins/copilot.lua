return {
	"github/copilot.vim",
	config = function()
		vim.keymap.set("i", "<M-Space>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
		vim.cmd("Copilot disable")
		vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>")
		vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>")
	end,
}
