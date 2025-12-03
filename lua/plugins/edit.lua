vim.pack.add({
	{ src = "https://github.com/monaqa/dial.nvim" },
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },
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
}
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
vim.keymap.set("n", "<c-a>", function()
	require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
	require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("n", "g<C-a>", function()
	require("dial.map").manipulate("increment", "gnormal")
end)
vim.keymap.set("n", "g<C-x>", function()
	require("dial.map").manipulate("decrement", "gnormal")
end)
vim.keymap.set("v", "<C-a>", function()
	require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("v", "<c-x>", function()
	require("dial.map").manipulate("decrement", "visual")
end)
vim.keymap.set("v", "g<C-a>", function()
	require("dial.map").manipulate("increment", "gvisual")
end)
vim.keymap.set("v", "g<C-x>", function()
	require("dial.map").manipulate("decrement", "gvisual")
end)

require("smart-splits").setup()
Utils.setup_keymaps(keys)
