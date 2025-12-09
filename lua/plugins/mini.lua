vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.icons" },
})

package.preload["nvim-web-devicons"] = function()
	require("mini.icons").mock_nvim_web_devicons()
	return package.loaded["nvim-web-devicons"]
end
require("mini.icons").setup({
	file = {
		[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
		["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
		["compose.yaml"] = { glyph = "󰡨", hl = "MiniIconsAzure" },
	},
	filetype = {
		dotenv = { glyph = "", hl = "MiniIconsYellow" },
		yaml = { glyph = "", hl = "MiniIconsPurple" },
		outline = { glyph = "󰱺", hl = "MiniIconsYellow" },
		nu = { glyph = "", hl = "MiniIconsGreen" },
		nushell = { glyph = "", hl = "MiniIconsGreen" },
	},
	lsp = {
		supermaven = { glyph = "", hl = "MiniIconsYellow" },
		fitten = { glyph = "", hl = "MiniIconsYellow" },
		copilot = { glyph = "", hl = "MiniIconsYellow" },
		codeium = { glyph = "", hl = "MiniIconsBlue" },
	},
})
