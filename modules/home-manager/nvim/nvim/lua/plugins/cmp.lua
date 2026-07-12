return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
		"onsails/lspkind.nvim",
		"roobert/tailwindcss-colorizer-cmp.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},

	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				autocomplete = { cmp.TriggerEvent.TextChanged },
				completeopt = "menu,menuone,noselect", -- standard Vim option
			},
			preselect = cmp.PreselectMode.Item,
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),

				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),
			sources = cmp.config.sources({
				-- LSP completions first
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "nvim_lsp_signature_help", priority = 900 },
				-- Snippets below LSP
				{ name = "luasnip", priority = 700 },
				-- Then none-ls / buffer / path
				{ name = "buffer", priority = 400 },
				{ name = "path", priority = 300 },
				{ name = "none-ls", priority = 200 },
			}),
			formatting = {
				format = function(entry, vim_item)
					-- lspkind icons
					vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol_text" })

					-- tailwindcss-colorizer
					if entry.source.name == "nvim_lsp" then
						local ok, tw = pcall(require, "tailwindcss-colorizer-cmp")
						if ok then
							vim_item = tw.formatter(entry, vim_item)
						end
					end
					return vim_item
				end,
			},
		})
	end,
}
