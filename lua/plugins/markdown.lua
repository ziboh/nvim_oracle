vim.pack.add({
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
	callback = function()
		local opts = {
			file_types = { "markdown", "Avante" },
			quote = { repeat_linebreak = true },
			win_options = {
				showbreak = { default = "", rendered = "  " },
				breakindent = { default = false, rendered = true },
				breakindentopt = { default = "", rendered = "" },
			},
		}

		require("render-markdown").setup(opts)

		vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#1e2124" })
		vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "#1e2124" })

		Snacks.toggle({
			name = "Render Markdown",
			get = function()
				return require("render-markdown.state").enabled
			end,
			set = function(enabled)
				local m = require("render-markdown")
				if enabled then
					m.enable()
				else
					m.disable()
				end
			end,
		}):map("<leader>um")
	end,
	once = true,
})
