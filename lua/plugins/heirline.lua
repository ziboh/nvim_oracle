vim.pack.add({
	{ src = "https://github.com/rebelot/heirline.nvim" },
})

Utils.create_autocmd_once("VimEnter", {
	group = vim.api.nvim_create_augroup("SetupHeirline", { clear = true }),
	callback = function()
		require("heirline").setup({
			statusline = require("config.heirline.statusline"),
		})
	end,
})
