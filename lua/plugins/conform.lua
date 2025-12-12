local project_dir = vim.env.PROJECT_DIRS
if project_dir ~= nil and vim.fn.isdirectory(vim.fs.joinpath(project_dir, "conform.nvim")) == 1 then
	vim.opt.rtp:append(vim.fs.joinpath(project_dir, "conform.nvim"))
else
	vim.pack.add({
		"https://github.com/stevearc/conform.nvim",
	})
end

Utils.create_autocmd_once("FileType", {
	callback = function()
		vim.g.autoformat = true
		require("conform").setup({
			formatters_by_ft = {
				nu = { "topiary_nu" },
				lua = { "stylua" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				python = function(bufnr)
					if require("conform").get_formatter_info("ruff_format", bufnr).available then
						return { "ruff_format" }
					else
						return { "isort", "black" }
					end
				end,
			},
			formatters = {
				topiary_nu = {
					command = "topiary",
					args = { "format", "--language", "nu" },
				},
			},
			default_format_opts = {
				lsp_format = "fallback", -- 当没有其他格式化程序时使用 LSP
			},
			format_on_save = function(bufnr)
				if vim.g.autoformat or vim.b[bufnr].autoformat then
					return { timeout_ms = 500, lsp_format = "fallback" }
				end
			end,
		})
		vim.keymap.set("n", "<leader>lf", function()
			require("conform").format()
		end, { noremap = true, silent = true, desc = "Formatting" })
		if vim.fn.executable("topiary") == 0 then
			Utils.install_topiary()
		end

		if not vim.uv.fs_stat(vim.fn.expand("~/.config") .. "/topiary") then
			Utils.update_topiary_nushell()
		end

		Snacks.toggle({
			name = "AutoFormat",
			get = function()
				return vim.g.autoformat
			end,
			set = function(value)
				if value == vim.g.autoformat then
					return
				else
					vim.g.autoformat = value
				end
			end,
		}):map("<leader>uf")
	end,
})
