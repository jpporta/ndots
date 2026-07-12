return {
	"stevearc/oil.nvim",
	config = function()
		require("oil").setup({
			columns = { "icon" },
			keymaps = {
				["g?"] = "actions.show_help",
				["gs"] = "actions.change_sort",
				["<CR>"] = "actions.select",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["g."] = "actions.toggle_hidden",
			},
			use_default_keymaps = false,
			view_options = {
				show_hidden = true,
				sort = { { "type", "asc" }, { "name", "asc" } },
			},
			skip_confirm_for_simple_edits = true,
		})

		vim.keymap.set("n", "-", function(dir)
			require("oil").open(dir)
		end, { desc = "Open parent directory" })
	end,
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
