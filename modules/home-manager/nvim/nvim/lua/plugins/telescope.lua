return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"xiyaowong/telescope-emoji",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		defaults = { mappings = { i = { ["<C-u>"] = false, ["<C-d>"] = false } } },
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
		},
		pickers = { colorscheme = { enable_preview = true } },
	},
	config = function()
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "emoji")
		vim.keymap.set(
			"n",
			"<leader>?",
			require("telescope.builtin").oldfiles,
			{ desc = "[?] Find recently opened files" }
		)
		vim.keymap.set("n", "<leader><space>", function()
			require("telescope.builtin").buffers({
				sort_mru = true,
				ignore_current_buffer = true,
			})
		end, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "[G]oto [R]eferences" })
		vim.keymap.set(
			"n",
			"<leader>ds",
			require("telescope.builtin").lsp_document_symbols,
			{ desc = "[D]ocument [S]ymbols" }
		)
		vim.keymap.set(
			"n",
			"<leader>ws",
			require("telescope.builtin").lsp_dynamic_workspace_symbols,
			{ desc = "[W]orkspace [S]ymbols" }
		)
		vim.keymap.set("n", "<leader>/", function()
			require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })
		vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set(
			"n",
			"<leader>sw",
			require("telescope.builtin").grep_string,
			{ desc = "[S]earch current [W]ord" }
		)
		vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>ss", require("telescope.builtin").git_files, { desc = "Search Git Files" })
		vim.keymap.set("n", "<leader>sb", ":Telescope file_browser<CR>", { desc = "File browser" })
		vim.keymap.set("n", "<leader>st", ":Telescope colorscheme<CR>", { desc = "Switch Theme" })
		vim.keymap.set("n", "<leader>se", ":Telescope emoji<CR>", { desc = "Search Emoji" })
	end,
	event = "VeryLazy",
}
