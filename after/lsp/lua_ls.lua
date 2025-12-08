local library = {
	"C:\\Users\\zibo\\AppData\\Local\\bob\\nightly\\share\\nvim\\runtime",
	vim.fs.joinpath(vim.fn.stdpath("data"), "/site/pack/core/opt/snacks.nvim"),
}
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
				library = library,
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
