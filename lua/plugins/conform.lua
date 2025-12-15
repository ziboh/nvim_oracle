vim.pack.add({
	"https://github.com/stevearc/conform.nvim",
})

Utils.mason_add_ensure_installed({ "biome", "prettierd" })

Utils.create_autocmd_once("FileType", {
	callback = function()
		vim.g.autoformat = true
		require("conform").setup({
			formatters_by_ft = {
				nu = { "topiary_nu" },
				lua = { "stylua" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "biome", "prettierd", stop_after_first = true },
				jsonc = { "biome" },
				json = { "biome" },
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
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
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

		-- 保存原始的 lsp_format.format 函数
		local lsp_format = require("conform.lsp_format")
		local original_format = lsp_format.format

		-- 包装 LSP 格式化函数
		---@diagnostic disable-next-line: duplicate-set-field
		lsp_format.format = function(options, callback)
			local bufnr = options.bufnr or vim.api.nvim_get_current_buf()
			local saved_buflisted = vim.bo[bufnr].buflisted

			original_format(options, function(err, did_edit)
				-- 恢复 buflisted 状态
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.bo[bufnr].buflisted = saved_buflisted
				end
				callback(err, did_edit)
			end)
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
