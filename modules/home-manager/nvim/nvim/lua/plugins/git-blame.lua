return {
	{
		"f-person/git-blame.nvim",
		lazy = true,
		cmd = { "GitBlameEnable", "GitBlameDisable", "GitBlameToggle" },
		keys = {
			{
				"<leader>gb",
				":GitBlameToggle<CR>",
				desc = "Toggle Git Blame",
				mode = "n",
			},
		},
	},
	{
		"sindrets/diffview.nvim",
		keys = {
			{
				"<leader>do",
				":DiffviewOpen<CR>",
				desc = "[D]iffview [O]pen",
				mode = "n",
			},
			{
				"<leader>dc",
				":DiffviewClose<CR>",
				desc = "[D]iffview [C]lose",
				mode = "n",
			},
		},
	},
}
