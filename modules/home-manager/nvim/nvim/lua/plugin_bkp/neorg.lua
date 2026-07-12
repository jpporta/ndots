return {
	"nvim-neorg/neorg",
	dependencies = { "vhyrro/luarocks.nvim", "nvim-treesitter" },
	lazy = false,
	version = "*",
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Documents/notes",
						},
						default_workspace = "notes",
					},
				},
			},
		})
	end,
}
