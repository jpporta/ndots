return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
		config = function()
			local setup, null_ls = pcall(require, "null-ls")
			if not setup then
				return
			end

			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			null_ls.setup({
				sources = {
					-- Code Actions
					require("none-ls.code_actions.eslint_d"),
					null_ls.builtins.code_actions.gitsigns, -- Optional: git-related code actions
					null_ls.builtins.code_actions.refactoring,
					-- Diagnostics
					require("none-ls.diagnostics.eslint_d"),
					null_ls.builtins.diagnostics.golangci_lint,
					-- Hover documentation (optional)
					null_ls.builtins.hover.dictionary,
				},
				vim.keymap.set("n", "<leader>rn", function()
					vim.lsp.buf.rename()
				end, { desc = "Rename Variable" }),
			})
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^7", -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{
		{
			"antosha417/nvim-lsp-file-operations",
			dependencies = {
				"nvim-lua/plenary.nvim",
				-- Uncomment whichever supported plugin(s) you use
				-- "nvim-tree/nvim-tree.lua",
				-- "nvim-neo-tree/neo-tree.nvim",
				-- "simonmclean/triptych.nvim"
			},
			config = function()
				require("lsp-file-operations").setup()
			end,
		},
	},
}
