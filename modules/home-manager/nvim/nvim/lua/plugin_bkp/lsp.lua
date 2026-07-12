return {
	{ "williamboman/mason.nvim", lazy = false, config = true },
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"html",
					"ts_ls",
					"tailwindcss",
					"gopls",
					"lua_ls",
					"csharp_ls",
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "folke/neodev.nvim", "j-hui/fidget.nvim", "hrsh7th/cmp-nvim-lsp" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local keymap = vim.keymap

			local opts = { noremap = true, silent = true }

			local on_attach = function(client, bufnr)
				opts.buffer = bufnr
				opts.desc = "[G]oto [D]eclaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				opts.desc = "[C]ode [A]ction"
				keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				opts.desc = "[G]oto [D]efinition"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				opts.desc = "[R]e[n]ame"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				opts.desc = "Diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				opts.desc = "File [D]iagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				opts.desc = "Hover Documentation"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				opts.desc = "Type Definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				opts.desc = "[G]oto [I]mplementation"
				keymap.set("n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts)
				opts.desc = "Signature Documentation"
				keymap.set("n", "<C-i>", vim.lsp.buf.signature_help, opts)
				opts.desc = "[W]orkspace [L]ist Folders"
				keymap.set("n", "<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
					},
					linehl = {
						[vim.diagnostic.severity.ERROR] = "Error",
						[vim.diagnostic.severity.WARN] = "Warn",
						[vim.diagnostic.severity.INFO] = "Info",
						[vim.diagnostic.severity.HINT] = "Hint",
					},
				},
			})

			local lspconfig = require("lspconfig")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = cmp_nvim_lsp.default_capabilities()
			-- local servers = {
			-- 	html = {
			-- 		"emmet-ls",
			-- 	},
			-- 	ts_ls = {
			-- 		filetypes = {
			-- 			"html",
			-- 			"css",
			-- 			"javascript",
			-- 			"typescript",
			-- 			"typescriptreact",
			-- 			"javascriptreact",
			-- 		},
			-- 	},
			-- 	tailwindcss = {
			-- 		filetypes = {
			-- 			"html",
			-- 			"css",
			-- 			"javascript",
			-- 			"typescript",
			-- 			"typescriptreact",
			-- 			"javascriptreact",
			-- 		},
			-- 	},
			-- 	gopls = {
			-- 		cmd = { "gopls" },
			-- 		filetypes = {
			-- 			"go",
			-- 			"gomod",
			-- 			"gowork",
			-- 			"gotmpl",
			-- 		},
			-- 	},
			-- 	lua_ls = {
			-- 		Lua = {
			-- 			workspace = { checkThirdParty = false },
			-- 			telemetry = { enable = false },
			-- 			diagnostics = { globals = { "vim" } },
			-- 		},
			-- 	},
			-- 	csharp_ls = {
			-- 		cmd = { "csharp-ls" },
			-- 		filetypes = {
			-- 			"cs",
			-- 			"csproj",
			-- 		},
			-- 	},
			-- }
			--
			-- for server, settings in pairs(servers) do
			-- 	lspconfig[server].setup({
			-- 		capabilities = capabilities,
			-- 		on_attach = on_attach,
			-- 		settings = settings,
			-- 		filetypes = (settings or {}).filetypes,
			-- 	})
			-- end
		end,
	},
}
