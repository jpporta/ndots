return {
	{
		"folke/zen-mode.nvim",
		opts = {
			window = {
				width = 80,
			},
			plugins = {
				options = {
					ruler = false,
					enabled = true,
				},
				kitty = {
					enabled = true,
				},
				gitsigns = {
					enabled = true,
				},
				tmux = { enabled = true },
				twilight = {
					enabled = true,
				},
			},
		},
		keys = {
			{
				"<leader>zm",
				":ZenMode<CR>",
				desc = "Zen Mode",
				mode = "n",
			},
		},
		cmd = {
			"ZenMode",
		},
	},
	{
		"folke/twilight.nvim",
		opts = {},
		cmd = { "Twilight" },
		keys = {
			{
				"<leader>tw",
				":Twilight<CR>",
				desc = "Twilight",
				mode = "n",
			},
		},
	},
	{
		"preservim/vim-pencil",
		cmd = { "Pencil", "NoPencil", "TogglePencil", "SoftPencil", "HardPencil" },
	},
}
