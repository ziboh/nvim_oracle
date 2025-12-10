vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})

Utils.create_autocmd_once("Filetype", {
	callback = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			default_format_opts = {
				lsp_format = "fallback", -- 当没有其他格式化程序时使用 LSP
			},
			format_on_save = {
				lsp_format = "fallback",
			},
		})
		vim.keymap.set("n", "<leader>lf", function()
			require("conform").format()
		end, { noremap = true, silent = true, desc = "Formatting" })
	end,
})
