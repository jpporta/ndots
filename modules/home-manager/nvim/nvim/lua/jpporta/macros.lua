local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
local ret = vim.api.nvim_replace_termcodes("<CR>", true, true, true)

vim.fn.setreg('o', "jjo€  - " ..esc.. "p4j0f:llv$hP3j0wv$hP" ..esc.. ":w" ..ret)
