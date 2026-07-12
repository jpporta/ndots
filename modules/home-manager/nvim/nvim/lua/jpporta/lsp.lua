vim.lsp.enable("ts_ls")
vim.lsp.enable("gopls")
-- vim.lsp.enable("tailwindcss")

-- Auto complete
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		-- if client:supports_method("textDocument/completion") then
		-- 	vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
		-- 	vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		-- 	vim.keymap.set("i", "<C-Space>", function()
		-- 		vim.lsp.completion.get()
		-- 	end)
		-- end
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = args.buf })
		-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	group = augroup,
		-- 	buffer = args.buf,
		-- 	callback = function()
		-- 		vim.cmd("Neoformat")
		-- 	end,
		-- })
		if client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true)

			vim.keymap.set("n", "gp", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end, {
				desc = "Toggle Inlay Hints",
			})
		end

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.type_definition()
		end, {
			desc = "Go to Type Definition",
		})
		vim.keymap.set("n", "gi", function()
			vim.lsp.buf.implementation()
		end, {
			desc = "Go to Implementation",
		})
	end,
})

vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
		},
	},
	update_in_insert = false,
	severity_sort = true,
})
