return {
	cmd = { 'gopls' },
	filetypes = {
		'go',
		'gomod',
		'gowork',
		'gotmpl',
		'gosum'
	},
	root_markers = {
		'go.mod',
		'go.work',
		'.git'
	},
	settings = {
		gopls = {
			gofumpt = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		}
	}
}
