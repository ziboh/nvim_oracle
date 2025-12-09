vim.pack.add({
	{ src = "https://github.com/chrisgrieser/nvim-origami" },
})

vim.o.foldcolumn = "0" -- '0' is not bad
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

Utils.create_autocmd_once("BufEnter", {
	callback = function()
		local opts = {
			foldtext = {
				lineCount = {
					template = "󰛁  %d lines", -- `%d` is replaced with the number of folded lines
					hlgroup = "Comment",
				},
			},
		}
		require("origami").setup(opts)
		vim.keymap.set("n", "L", function()
			require("origami").dollar()
		end)
		vim.keymap.set("n", "H", function()
			require("origami").caret()
		end)
	end,
})
