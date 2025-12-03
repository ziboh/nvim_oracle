vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
})

require("catppuccin").setup({
	flavour = "macchiato", -- latte, frappe, macchiato, mocha ,auto
	transparent_background = true,
	term_colors = true,
	highlight_overrides = {
		mocha = function(mocha)
			return {
				CursorLineNr = { fg = mocha.yellow },
				RenderMarkdownCode = { bg = mocha.crust },
				Pmenu = { bg = mocha.base },
			}
		end,
	},
})
vim.cmd("colorscheme catppuccin")
vim.api.nvim_set_hl(0, "statusline", { bg = "NONE" })
vim.api.nvim_set_hl(0, "Comment", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "NONE" })
vim.api.nvim_set_hl(0, "YankyYanked", { fg = "#161b22", bg = "#ff8f62" })
