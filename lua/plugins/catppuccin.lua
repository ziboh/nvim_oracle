vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
})

require("catppuccin").setup({
	transparent_background = true,
	term_colors = true,
	highlight_overrides = {
		mocha = function(mocha)
			return {
				CursorLineNr = { fg = mocha.yellow },
				FlashCurrent = { bg = mocha.peach, fg = mocha.base },
				FlashMatch = { bg = mocha.red, fg = mocha.base },
				FlashLabel = { bg = mocha.teal, fg = mocha.base },
				NormalFloat = { bg = "NONE" },
				FloatBorder = { bg = mocha.base },
				FloatTitle = { bg = mocha.base },
				RenderMarkdownCode = { bg = mocha.crust },
				Pmenu = { bg = mocha.base },
			}
		end,
	},
})
vim.cmd("colorscheme catppuccin")
vim.cmd.hi("statusline guibg=NONE")
vim.cmd.hi("Comment gui=none")
