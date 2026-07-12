return {
	'prettier/vim-prettier',
	ft = {
		'javascript',
		'javascriptreact',
		'javascript.jsx',
		'typescript',
		'typescriptreact',
		'typescript.tsx',
		"vue",
		"css",
		"scss",
		"less",
		"html",
		"json",
		"jsonc",
		"yaml",
		"markdown",
		"graphql",
		"handlebars",
		"svelte",
		"astro",
		"htmlangular",
	},
		config = function()
			vim.g["prettier#autoformat"] = 1
			vim.g["prettier#autoformat_require_pragma"] = 0
			vim.g["prettier#quickfix_enabled"] = 0
				-- use prettier with prettierd
			vim.b["prettier_exec_cmd"] = "prettierd"
		end,
		keys = {
			{
				"<leader>f",
				function()
					vim.cmd("Prettier")
				end,
				desc = "Format with Prettier",
			},
		},
}
