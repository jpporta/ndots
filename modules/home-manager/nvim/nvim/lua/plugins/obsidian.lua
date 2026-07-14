return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>oo",
			function()
				vim.cmd("ObsidianToday")
			end,
			desc = "[O]bsidian T[o]day",
		},
		{
			"<leader>os",
			function()
				vim.cmd("ObsidianSearch")
			end,
			desc = "[O]bsidian [S]earch",
		},
		{
			"<leader>on",
			function()
				vim.cmd("ObsidianNew")
			end,
			desc = "[O]bsidian [N]ew",
		},
		{
			"<leader>oe",
			":ObsidianExtractNote<CR>",
			desc = "[O]bsidian [E]xtract",
			mode = "v",
		},
		{
			"<leader>ot",
			":ObsidianTemplate<CR>",
			desc = "[O]bsidian [T]emplate",
			mode = "n",
		},
	},
	opts = {

		mappings = {
			-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			-- Toggle check-boxes.
			["<leader>ch"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
		},
		note_id_func = function(title)
			local suffix = ""
			if title ~= nil then
				-- If title is given, transform it into valid file name.
				suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				-- If title is nil, just add 4 random uppercase letters to the suffix.
				for _ = 1, 4 do
					suffix = suffix .. string.char(math.random(65, 90))
				end
			end
			return os.date("%s", os.time()) .. suffix
		end,
		follow_url_func = function(url)
			vim.ui.open(url) -- need Neovim 0.10.0+
		end,
		-- Optional, configure additional syntax highlighting / extmarks.
		ui = {
			enable = false, -- set to false to disable all additional syntax features
			update_debounce = 200, -- update delay after a text change (in milliseconds)
			-- Define how various check-boxes are displayed
			checkboxes = {
				-- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
				[" "] = { char = " ", hl_group = "ObsidianTodo" },
				["x"] = { char = "", hl_group = "ObsidianDone" },
				[">"] = { char = "", hl_group = "ObsidianRightArrow" },
				["<"] = { char = "", hl_group = "ObsidianLeftArrow" },
				["~"] = { char = "", hl_group = "ObsidianTilde" },
				["v"] = { char = "", hl_group = "ObsidianPlay" },
				["?"] = { char = "", hl_group = "ObsidianQuestion" },
				["I"] = { char = "", hl_group = "ObsidianIdea" },
			},
			external_link_icon = {
				char = "",
				hl_group = "ObsidianExtLinkIcon",
			},
			-- Replace the above with this if you don't have a patched font:
			-- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			reference_text = { hl_group = "ObsidianRefText" },
			highlight_text = { hl_group = "ObsidianHighlightText" },
			tags = { hl_group = "ObsidianTag" },
			hl_groups = {
				-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
				ObsidianTodo = { bold = true, fg = "#7f849c" },
				ObsidianDone = { bold = true, fg = "#a6e3a1" },
				ObsidianPlay = { bold = true, fg = "#89b4fa" },
				ObsidianRightArrow = { bold = true, fg = "#fab387" },
				ObsidianLeftArrow = { bold = true, fg = "#f5c2e7" },
				ObsidianTilde = { bold = true, fg = "#f38ba8" },
				ObsidianQuestion = { bold = true, fg = "#b4befe" },
				ObsidianIdea = { bold = true, fg = "#f9e2af" },
				ObsidianRefText = { underline = true, fg = "#c792ea" },
				ObsidianExtLinkIcon = { fg = "#c792ea" },
				ObsidianTag = { italic = true, fg = "#89ddff" },
				ObsidianHighlightText = { bg = "#75662e" },
			},
		},
		--------------------------------
		notes_subdir = "",
		new_notes_location = "notes_subdir",
		workspaces = {
			{
				name = "personal",
				path = "~/docs/personal",
			},
		},
		daily_notes = {
			folder = "journal",
			date_format = "%Y-%m-%d",
			default_tags = { "journal" },
			template = "journal"
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},

		templates = {
			subdir = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},
		picker = {
			name = "telescope.nvim",
			note_mappings = {
				-- Create a new note from your query.
				new = "<C-x>",
				-- Insert a link to the selected note.
				insert_link = "<C-l>",
			},
			tag_mappings = {
				-- Add tag(s) to current note.
				tag_note = "<C-x>",
				-- Insert a tag at the current location.
				insert_tag = "<C-l>",
			},
		},
	},
}
