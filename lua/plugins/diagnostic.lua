vim.pack.add({
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
})

local diagnostics = {
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = Utils.icons.diagnostics.Error,
			[vim.diagnostic.severity.HINT] = Utils.icons.diagnostics.Hint,
			[vim.diagnostic.severity.WARN] = Utils.icons.diagnostics.Warn,
			[vim.diagnostic.severity.INFO] = Utils.icons.diagnostics.Info,
		},
	},
}
vim.diagnostic.config(diagnostics)

Utils.create_autocmd_once("VimEnter", {
	callback = function()
		require("tiny-inline-diagnostic").setup({
			preset = "ghost",
		})
	end,
})
