vim.pack.add({
	{ src = "https://github.com/mistweaverco/kulala.nvim" },
})

vim.filetype.add({
	extension = {
		["http"] = "http",
	},
})

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "http",
	callback = function()
		require("kulala").setup()
	end,
	once = true,
})
