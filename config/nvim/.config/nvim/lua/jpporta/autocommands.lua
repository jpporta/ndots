vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.http", command = "set ft=http" })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.templ", command = "set ft=templ" })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
pattern = "**/inbox/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md",
callback = function()
    -- Run `date` and capture output
    local handle = io.popen('date "+%H:%M"')
    local time = handle:read("*l")
    handle:close()

    -- Build the line with a trailing colon and space
    local line = time .. ":  "

    -- Append it at the bottom
    local last_line = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { line })

    -- Place cursor at the end of the inserted line
    vim.api.nvim_win_set_cursor(0, { last_line + 1, #line })

    -- Enter insert mode
    vim.cmd("startinsert")
  end,
})

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})
