return {
	cmd = { "lua-language-server", "--locale=zh-cn" },
	enabled = true,
	settings = {
		Lua = {
			diagnostics = {
				disable = {
					"trailing-space",
				},
			},
			workspace = {
				checkThirdParty = false,
			},
			codeLens = {
				enable = true,
			},
			completion = {
				callSnippet = "Replace",
			},
			doc = {
				privateName = { "^_" },
			},
			hint = {
				enable = true,
				setType = false,
				paramType = true,
				paramName = "Disable",
				semicolon = "Disable",
				arrayIndex = "Disable",
			},
		},
	},
}
