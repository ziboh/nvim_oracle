vim.pack.add({
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
})
vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#282c34" })
vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "#282c34" })
vim.api.nvim_set_hl(0, "RenderMarkdown_RenderMarkdownCodeBorder_bg_as_fg", { fg = "#282c34" })
Utils.create_autocmd_once("FileType", {
	pattern = "markdown",
	callback = function()
		local opts = {
			file_types = { "markdown", "Avante" },
			quote = { repeat_linebreak = true },
			anti_conceal = {
				disabled_modes = { "n" },
			},
			completions = {
				-- Settings for blink.cmp completions source
				blink = { enabled = true },
				-- Settings for in-process language server completions
				lsp = { enabled = true },
			},
			win_options = {
				showbreak = { default = "", rendered = "  " },
				breakindent = { default = false, rendered = true },
				breakindentopt = { default = "", rendered = "" },
			},
		}

		require("render-markdown").setup(opts)

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
})
