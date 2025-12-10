vim.pack.add({
	"https://github.com/folke/lazydev.nvim",
})

local opts = {
	library = {
		-- { path = "${3rd}/luv/library", words = { "vim%.uv" } },
		{ path = "snacks.nvim", words = { "Snacks" } },
		-- { path = "wezterm-types", mods = { "wezterm" } },
	},
}
require("lazydev").setup(opts)
