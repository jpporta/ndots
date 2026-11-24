return {
	"vim-scripts/icalendar.vim",
	setup = function()
		vim.filetype.add({
			extension = {
				ics = "icalendar",
			},
		})
	end,
}
