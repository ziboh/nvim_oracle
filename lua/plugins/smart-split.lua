vim.pack.add({
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },
})

Utils.create_autocmd_once("BufEnter", {
	callback = function()
		local keys = {
			{
				"<C-A-F8>",
				function()
					require("smart-splits").move_cursor_left()
				end,
				desc = "Move to left split",
			},
			{
				"<C-j>",
				function()
					require("smart-splits").move_cursor_down()
				end,
				desc = "Move to below split",
			},
			{
				"<C-k>",
				function()
					require("smart-splits").move_cursor_up()
				end,
				desc = "Move to above split",
			},
			{
				"<C-l>",
				function()
					if vim.bo.filetype == "snacks_explorer_list" or vim.bo.filetype == "snacks_explorer_input" then
						local win_config = vim.api.nvim_win_get_config(0)
						if win_config.zindex == 33 then -- Snack explorer is on same zindex as main window
							vim.cmd("wincmd l")
						end
					else
						require("smart-splits").move_cursor_right()
					end
				end,
				desc = "Move to right split",
			},
			{
				"<C-Up>",
				function()
					require("smart-splits").resize_up()
				end,
				desc = "Resize split up",
			},
			{
				"<C-Down>",
				function()
					require("smart-splits").resize_down()
				end,
				desc = "Resize split down",
			},
			{
				"<C-Left>",
				function()
					require("smart-splits").resize_left()
				end,
				desc = "Resize split left",
			},
			{
				"<C-Right>",
				function()
					require("smart-splits").resize_right()
				end,
				desc = "Resize split right",
			},
		}
		require("smart-splits").setup({})
		Utils.setup_keymaps(keys)
	end,
})
