return {
	"nvimdev/guard.nvim",
	dependencies = { "nvimdev/guard-collection" },
	ft = {
		"typescript",
		"javascript",
		"typescriptreact",
		"json",
		"markdown",
		"lua",
		"go",
	},
	config = function()
		local ft = require("guard.filetype")
		local mdformat = {
			cmd = "mdformat",
			stdin = true,
		}

		ft("typescript"):fmt("prettierd"):lint("eslint_d")
		ft("javascript"):fmt("prettierd"):lint("eslint_d")
		ft("typescriptreact"):fmt("prettierd"):lint("eslint_d")
		ft("json"):fmt("prettierd"):lint("eslint_d")
		ft("markdown"):fmt(mdformat):lint("eslint_d")
		ft("lua"):fmt("stylua")
		ft("go"):fmt("gofmt"):lint("golangci_lint")

		vim.keymap.set("n", "<leader>f", "<cmd>Guard fmt<CR>", { desc = "Format" })

		vim.g.guard_config = {
			fmt_on_save = true,
			save_on_fmt = false,
		}
	end,
}
