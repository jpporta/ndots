return {
	"mhartington/formatter.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>f",
			":Format<CR>",
			desc = "Format file",
			mode = "n",
		},
	},
	config = function()
		require("formatter").setup({
			filetype = {
				javascript = { require("formatter.filetypes.javascript").prettierd },
				typescript = { require("formatter.filetypes.typescript").prettierd },
				javascriptreact = { require("formatter.filetypes.javascriptreact").prettierd },
				typescriptreact = { require("formatter.filetypes.typescriptreact").prettierd },
				json = { require("formatter.filetypes.json").jq },
				lua = { require("formatter.filetypes.lua").stylua },
				rust = { require("formatter.filetypes.rust").rustfmt },
				go = { require("formatter.filetypes.go").goimports },
				markdown = { require("formatter.filetypes.markdown").prettierd },
				html = { require("formatter.filetypes.html").prettierd },
				css = { require("formatter.filetypes.css").prettierd },
				nix = { require("formatter.filetypes.nix").nixpkgs_fmt },
				["*"] = {
					require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			},
		})
		vim.api.nvim_create_autocmd("BufWritePost", { command = "FormatWriteLock" })
	end,
}
-- return {
-- 	"stevearc/conform.nvim",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	cmd = "ConformInfo",
-- 	opts = {
-- 		formatters_by_ft = {
-- 			javascript = { { "prettier", "jsbeautify" } },
-- 			typescript = { "prettier" },
-- 			javascriptreact = { { "prettier", "jsbeautify" } },
-- 			typescriptreact = { "prettier" },
-- 			json = { "prettier" },
-- 			lua = { "stylua" },
-- 			rust = { "rustfmt" },
-- 			go = { "goimports" },
-- 			markdown = { { "deno_fmt", "prettier", "prettierd" } },
-- 			html = { "prettier" },
-- 			css = { "prettier" },
-- 		},
-- 		format_on_save = function(bufnr)
-- 			-- Disable with a global or buffer-local variable
-- 			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
-- 				return
-- 			end
-- 			return { timeout_ms = 500, lsp_fallback = true }
-- 		end,
-- 	},
-- 	keys = {
-- 		{
-- 			"<leader>f",
-- 			function()
-- 				require("conform").format({
-- 					lsp_fallback = true,
-- 					async = true,
-- 				})
-- 			end,
-- 			desc = "Format file",
-- 		},
-- 	},
-- 	config = function()
-- 		local notify = require("notify")
-- 		local function show_notification(message, level)
-- 			notify(message, level, { title = "conform.nvim" })
-- 		end
-- 		vim.api.nvim_create_user_command("FormatToggle", function(args)
-- 			local is_global = not args.bang
-- 			if is_global then
-- 				vim.g.disable_autoformat = not vim.g.disable_autoformat
-- 				if vim.g.disable_autoformat then
-- 					show_notification("Autoformat-on-save disabled globally", "info")
-- 				else
-- 					show_notification("Autoformat-on-save enabled globally", "info")
-- 				end
-- 			else
-- 				vim.b.disable_autoformat = not vim.b.disable_autoformat
-- 				if vim.b.disable_autoformat then
-- 					show_notification("Autoformat-on-save disabled for this buffer", "info")
-- 				else
-- 					show_notification("Autoformat-on-save enabled for this buffer", "info")
-- 				end
-- 			end
-- 		end, {
-- 			desc = "Toggle autoformat-on-save",
-- 			bang = true,
-- 		})
-- 		vim.api.nvim_create_user_command("Format", function(args)
-- 			local range = nil
-- 			if args.count ~= -1 then
-- 				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
-- 				range = {
-- 					start = { args.line1, 0 },
-- 					["end"] = { args.line2, end_line:len() },
-- 				}
-- 			end
-- 			require("conform").format({ async = true, lsp_fallback = true, range = range })
-- 		end, { range = true })
-- 	end,
-- }
