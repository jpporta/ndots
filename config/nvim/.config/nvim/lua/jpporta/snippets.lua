local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

vim.keymap.set({ "i", "s" }, "<A-k>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<A-j>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })

local console_log_snippet = s("cl", {
	t("console.log('"),
	i(1, "var"),
	t(":', "),
	rep(1),
	t(");"),
})

local feature_prompt_snippet = s(
	"pt",
	fmt(
		[[
# {}

## Problem
{}

## Solution
{}

## Variables
{}

## Implementation Notes
{}

## Workflow
{}

## Deliverables
{}

## Definition of Done
{}

## How you are graded
{}
]],
		{
			i(1),
			i(2),
			i(3),
			i(4),
			i(5),
			i(6),
			i(7),
			i(8),
			i(9),
		}
	)
)

ls.add_snippets("typescript", { console_log_snippet })
ls.add_snippets("javascript", { console_log_snippet })
ls.add_snippets("typescriptreact", { console_log_snippet })
ls.add_snippets("javascriptreact", { console_log_snippet })
ls.add_snippets("markdown", { feature_prompt_snippet })
