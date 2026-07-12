return {
	"sbdchd/neoformat",
	cmd = { "Neoformat" },
	keys = {
		{
			"<leader>f",
			function()
				vim.cmd("Neoformat")
			end,
			desc = "Format",
		},
	},
	config = function()
		vim.g.neoformat_try_node_exe = 1
		vim.g.neoformat_enabled_go = { "gofmt", "goimports" } -- tries gofmt first, then goimports

		-- Optional: Configure specific formatter options
		-- For gofmt (usually no args needed)
		vim.g.neoformat_go_gofmt = {
			exe = "gofmt",
			args = {},
			stdin = 1, -- send buffer data via stdin
		}

		-- For goimports (if you want to use it)
		vim.g.neoformat_go_goimports = {
			exe = "goimports",
			args = {},
			stdin = 1,
		}
	end,
}
