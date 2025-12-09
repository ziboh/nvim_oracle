vim.pack.add({
	{ src = "https://github.com/sustech-data/wildfire.nvim" },
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		require("wildfire").setup({
			surrounds = {
				{ "(", ")" },
				{ "{", "}" },
				{ "<", ">" },
				{ "[", "]" },
			},
			filetype_exclude = { "qf", "outline" }, --keymaps will be unset in excluding filetypes
		})
	end,
	once = true,
})
