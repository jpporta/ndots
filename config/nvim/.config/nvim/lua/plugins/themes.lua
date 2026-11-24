return {
	-- {
	--      "rebelot/kanagawa.nvim", -- neorg needs a colorscheme with treesitter support
	--      config = function()
	--          vim.cmd.colorscheme("kanagawa")
	--      end,
	--    },
	{
		"RRethy/base16-nvim",
		priority = 1000,
	},
	{
		"EdenEast/nightfox.nvim",
		priority = 1000, -- Ensure it loads first
	},
	{
		"shaunsingh/nord.nvim",
		priority = 1000, -- Ensure it loads first
	},
	{
		"Mofiqul/dracula.nvim",
		priority = 1000, -- Ensure it loads first
	},
	-- {
	-- 	"olimorris/onedarkpro.nvim",
	-- 	priority = 1000, -- Ensure it loads first
	-- },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
	},
	{ "sainnhe/everforest", priority = 1000 },
	{ "kdheepak/monochrome.nvim", priority = 1000 },
	{ "ellisonleao/gruvbox.nvim", priority = 1000 },
	{
		"xiyaowong/transparent.nvim",
		priority = 1000,
		opts = {
			groups = {
				"Normal",
				"NormalNC",
				"Comment",
				"Constant",
				"Special",
				"Identifier",
				"Statement",
				"PreProc",
				"Type",
				"Underlined",
				"Todo",
				"String",
				"Function",
				"Conditional",
				"Repeat",
				"Operator",
				"Structure",
				"LineNr",
				"NonText",
				"SignColumn",
				"CursorLine",
				"CursorLineNr",
				"StatusLine",
				"StatusLineNC",
				"EndOfBuffer",
			},
			extra_groups = {
				"NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
				"NvimTreeNormal", -- NvimTree
			},
		},
	},
	-- {
	-- 	"fynnfluegge/monet.nvim",
	-- 	name = "monet",
	-- 	opts = {
	-- 		tranparent_background = true,
	-- 		dark_mode = true,
	-- 	},
	-- },
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {},
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
	},
	-- { "kepano/flexoki-neovim", priority = 1000, name = "flexoki" },
	-- { "jacoborus/tender.vim", priority = 1000, name = "tender" },
	-- { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
	-- {
	-- 	"scottmckendry/cyberdream.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("cyberdream").setup({
	-- 			-- Recommended - see "Configuring" below for more config options
	-- 			transparent = true,
	-- 			italic_comments = true,
	-- 			hide_fillchars = true,
	-- 			borderless_telescope = true,
	-- 			terminal_colors = true,
	-- 		})
	-- 		vim.cmd("colorscheme cyberdream") -- set the colorscheme
	-- 	end,
	-- },
	{ "rose-pine/neovim", as = "rose-pine" },
	{ "Shatur/neovim-ayu" },
	{
		"lalitmee/cobalt2.nvim",
		dependencies = { "tjdevries/colorbuddy.nvim", tag = "v1.0.0" },
	},
	{ "tanvirtin/monokai.nvim" },

	{
		"alexwu/nvim-snazzy",
		dependencies = { "rktjmp/lush.nvim" },
		lazy = false,
		priority = 1000,
	},
}
