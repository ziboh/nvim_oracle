vim.pack.add({
	"https://github.com/NMAC427/guess-indent.nvim",
})

Utils.create_autocmd_once("InsertEnter", {
	callback = function()
		require("guess-indent").setup({})
	end,
})
