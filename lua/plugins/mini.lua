vim.pack.add({
	"https://github.com/nvim-mini/mini.hipatterns",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/nvim-mini/mini.pairs",
})

local hipatterns_loaded = false
Utils.create_autocmd_once({ "BufReadPre", "BufNewFile" }, {
	callback = function()
		if hipatterns_loaded then
			return
		end
		hipatterns_loaded = true
		local hipatterns = require("mini.hipatterns")
		hipatterns.setup({
			highlighters = {
				-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
				-- highlight hex color strings (`#rrggbb`) using that color
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		})
	end,
})

Utils.create_autocmd_once("BufEnter", {
	callback = function()
		local opts = {
			modes = { insert = true, command = true, terminal = false },
			-- skip autopair when next character is one of these
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			-- skip autopair when the cursor is inside these treesitter nodes
			skip_ts = { "string" },
			-- skip autopair when next character is closing pair
			-- and there are more closing pairs than opening pairs
			skip_unbalanced = true,
			-- better deal with markdown code blocks
			markdown = true,
		}
		Utils.mini.pairs(opts)
	end,
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
		["dot_gitconfig"] = { glyph = "󰒓", hl = "MiniIconsOrange" },
	},
	extension = {
		age = { glyph = "", hl = "MiniIconsOrange" },
	},
	filetype = {
		["markdown.gh"] = { glyph = "", hl = "MiniIconsYellow" },
		dotenv = { glyph = "", hl = "MiniIconsYellow" },
		yaml = { glyph = "", hl = "MiniIconsPurple" },
		["yaml.chezmoitmpl"] = { glyph = "", hl = "MiniIconsPurple" },
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
