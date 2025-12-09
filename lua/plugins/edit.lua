require("plugins.rooter")
require("plugins.chezmoi")
require("plugins.autopairs")
require("plugins.wildfire")
require("plugins.kulala")


vim.pack.add({
	{ src = "https://github.com/monaqa/dial.nvim" },
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local augend = require("dial.augend")
		require("dial.config").augends:register_group({
			default = {
				augend.integer.alias.decimal,
				augend.integer.alias.hex,
				augend.date.alias["%Y/%m/%d"],
				augend.constant.alias.bool,
				augend.semver.alias.semver,
				augend.date.new({
					pattern = "%B", -- titlecased month names
					default_kind = "day",
				}),
				augend.constant.new({
					elements = {
						"january",
						"february",
						"march",
						"april",
						"may",
						"june",
						"july",
						"august",
						"september",
						"october",
						"november",
						"december",
					},
					word = true,
					cyclic = true,
				}),
				augend.constant.new({
					elements = {
						"Monday",
						"Tuesday",
						"Wednesday",
						"Thursday",
						"Friday",
						"Saturday",
						"Sunday",
					},
					word = true,
					cyclic = true,
				}),
				augend.constant.new({
					elements = {
						"monday",
						"tuesday",
						"wednesday",
						"thursday",
						"friday",
						"saturday",
						"sunday",
					},
					word = true,
					cyclic = true,
				}),
				augend.case.new({
					types = { "camelCase", "PascalCase", "snake_case", "SCREAMING_SNAKE_CASE" },
				}),
			},
		})
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
					require("smart-splits").move_cursor_right()
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
			{
				"<c-a>",
				function()
					require("dial.map").manipulate("increment", "normal")
				end,
				desc = "Increment under cursor",
			},
			{
				"<C-x>",
				function()
					require("dial.map").manipulate("decrement", "normal")
				end,
				desc = "Decrement under cursor",
			},
			{
				"g<C-a>",
				function()
					require("dial.map").manipulate("increment", "gnormal")
				end,
				desc = "Increment globally under cursor",
			},
			{
				"g<C-x>",
				function()
					require("dial.map").manipulate("decrement", "gnormal")
				end,
				desc = "Decrement globally under cursor",
			},
			{
				"<C-a>",
				function()
					require("dial.map").manipulate("increment", "visual")
				end,
				mode = "v",
				desc = "Increment in visual mode",
			},
			{
				"<c-x>",
				function()
					require("dial.map").manipulate("decrement", "visual")
				end,
				mode = "v",
				desc = "Decrement in visual mode",
			},
			{
				"g<C-a>",
				function()
					require("dial.map").manipulate("increment", "gvisual")
				end,
				mode = "v",
				desc = "Increment globally in visual mode",
			},
			{
				"g<C-x>",
				function()
					require("dial.map").manipulate("decrement", "gvisual")
				end,
				mode = "v",
				desc = "Decrement globally in visual mode",
			},
		}
		require("smart-splits").setup({})
		Utils.setup_keymaps(keys)
	end,
	once = true,
})
