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
	},
}
