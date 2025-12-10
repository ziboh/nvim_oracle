vim.pack.add({
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})
Utils.create_autocmd_once({ "BufReadPre", "BufNewFile" }, {
	callback = function()
		require("bufferline").setup({
			options = {
				close_command = function(n)
					Snacks.bufdelete(n)
				end,
				right_mouse_command = function(n)
					Snacks.bufdelete(n)
				end,
				separator_style = { "", "" },
				diagnostics = "nvim_lsp",
				always_show_bufferline = true,
				diagnostics_indicator = function(_, _, diag)
					local icons = Utils.icons.diagnostics
					local ret = (diag.error and icons.Error .. diag.error .. " " or "")
						.. (diag.warning and icons.Warn .. diag.warning or "")
					return vim.trim(ret)
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "Directory",
						text_align = "left",
					},
					{
						filetype = "snacks_layout_box",
					},
				},
			},
		})

		vim.api.nvim_set_hl(0, "BufferLineSeparator", { fg = "#45aff5" })
		vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = "#45aff5" })

		local keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
			{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
			{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
			{ "<leader>bc", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close All Other Buffers" },
			{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
			{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
			{ "<C-A-F10>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<C-A-1>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<C-]>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		}
		Utils.setup_keymaps(keys)
	end,
})
