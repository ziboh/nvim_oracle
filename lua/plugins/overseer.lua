vim.pack.add({
	"https://github.com/stevearc/overseer.nvim",
})

Utils.create_autocmd_once("InsertEnter", {
	callback = function()
		local opts = {}

		local keys = {
			{ "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Task list" },
			{ "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run task" },
			{ "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
			{ "<leader>oi", "<cmd>OverseerInfo<cr>", desc = "Overseer Info" },
			{ "<leader>ob", "<cmd>OverseerBuild<cr>", desc = "Task builder" },
			{ "<leader>ow", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
			{ "<leader>oc", "<cmd>OverseerClearCache<cr>", desc = "Clear cache" },
		}
		Utils.setup_keymaps(keys)
		require("overseer").setup(opts)
	end,
})
