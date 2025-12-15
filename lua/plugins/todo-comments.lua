vim.pack.add({
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
})

local todo_comments_loaded = false
Utils.create_autocmd_once({ "BufReadPre", "BufNewFile" }, {
	callback = function()
		if todo_comments_loaded then
			return
		end
		require("todo-comments").setup({
			highlight = {
				comments_only = true, -- 只在注释中高亮
				exclude = { "markdown" }, -- 排除 markdown 文件类型
			},
		})
		local keys = {
			{
				"<leader>st",
				function()
					---@diagnostic disable-next-line: undefined-field
					Snacks.picker.todo_comments()
				end,
				desc = "Todo",
			},
			{
				"<leader>sT",
				function()
					---@diagnostic disable-next-line: undefined-field
					Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
				end,
				desc = "Todo/Fix/Fixme",
			},
		}
		Utils.setup_keymaps(keys)
	end,
})
