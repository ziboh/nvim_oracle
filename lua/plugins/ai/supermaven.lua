vim.pack.add({
	{ src = "https://github.com/supermaven-inc/supermaven-nvim" },
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		local opts = {
			keymaps = {
				accept_suggestion = nil, -- handled by nvim-cmp / blink.cmp
			},
			disable_inline_completion = vim.g.ai_cmp,
			ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
		}

		require("supermaven-nvim").setup(opts)

		Snacks.toggle({
			name = "SuperMaven",
			get = function()
				return vim.g.supermaven_enabled
			end,
			set = function(enabled)
				if enabled then
					vim.g.supermaven_enabled = true
				else
					vim.g.supermaven_enabled = false
				end
			end,
		}):map("<leader>as")
	end,
	once = true,
})
