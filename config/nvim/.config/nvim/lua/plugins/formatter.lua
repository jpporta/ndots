return {
	"sbdchd/neoformat",
	cmd = { "Neoformat" },
	keys = {
		{
			"<leader>f",
			function()
				local ft = vim.bo.filetype
				if ft == "typescript" or ft == "typescriptreact" then
					vim.cmd("Neoformat prettierd")
					vim.cmd("Neoformat eslint_d") -- the repo's lint fixes (quotes, semicolons)
				else
					vim.cmd("Neoformat")
				end
			end,
			desc = "Format",
		},
	},
	config = function()
		vim.g.neoformat_try_node_exe = 1
		vim.g.neoformat_enabled_go = { "gofmt", "goimports" } -- tries gofmt first, then goimports
		vim.g.neoformat_enabled_rust = { "rustfmt" } -- default, but explicit

		local eslint_d = {
			exe = "eslint_d",
			args = {
				"--flag",
				"v10_config_lookup_from_file", -- find services/app/eslint.config.js from the file, not cwd
				"--stdin",
				"--stdin-filename",
				'"%:p"',
				"--fix-to-stdout",
			},
			stdin = 1,
			try_node_exe = 1,
		}
		vim.g.neoformat_typescriptreact_eslint_d = eslint_d
		vim.g.neoformat_typescript_eslint_d = eslint_d
		vim.g.neoformat_enabled_typescriptreact = { "prettierd", "eslint_d" }
		vim.g.neoformat_enabled_typescript = { "prettierd", "eslint_d" }
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
