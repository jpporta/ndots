return {
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		opts = {
			-- or "fzf-lua" or "snacks" or "default"
			picker = "telescope",
			-- bare Octo command opens picker of commands
			enable_builtin = true,
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			-- OR "ibhagwan/fzf-lua",
			-- OR "folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons", -- optional if file_panel.icons is a function
		},
	},
	{
		"https://github.com/ck-zhang/obfuscate.nvim",
		keys = {
			{
				"<C-t>",
				function()
					require("obfuscate").toggle()
				end,
				desc = "Toggle Obfuscate",
				mode = { "n", "v" },
			},
		},
	},
}
