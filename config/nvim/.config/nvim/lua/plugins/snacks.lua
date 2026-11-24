return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = [[
     ██╗██████╗ ██████╗  ██████╗ ██████╗ ████████╗ █████╗ 
     ██║██╔══██╗██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗
     ██║██████╔╝██████╔╝██║   ██║██████╔╝   ██║   ███████║
██   ██║██╔═══╝ ██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║
╚█████╔╝██║     ██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║
 ╚════╝ ╚═╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
                                                          ]],
				-- Same as the snacks defaults, except `n` opens a markdown scratch buffer
				keys = {
					{ icon = "", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{
						icon = "",
						key = "n",
						desc = "New File",
						action = ":ene | setfiletype markdown | startinsert",
					},
					{
						icon = "󰮗",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = "",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = "",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{
						icon = "󰒲",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = "󰈆", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
		explorer = { enabled = false },
		indent = { enabled = false },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		image = { enabled = true },
		gh = { enabled = true },
		git = { enabled = true },
	},
	keys = {
		{
			"<leader>gi",
			function()
				Snacks.picker.gh_issue()
			end,
			desc = "GitHub Issues (open)",
		},
		{
			"<leader>gI",
			function()
				Snacks.picker.gh_issue({ state = "all" })
			end,
			desc = "GitHub Issues (all)",
		},
		{
			"<leader>gp",
			function()
				Snacks.picker.gh_pr()
			end,
			desc = "GitHub Pull Requests (open)",
		},
		{
			"<leader>gP",
			function()
				Snacks.picker.gh_pr({ state = "all" })
			end,
			desc = "GitHub Pull Requests (all)",
		},
	},
}
