local opts = {
	servers = {
		rime_ls = {
			offset_encoding = "utf-8",
			on_attach = Utils.rime.rime_on_attach,
			init_options = {
				enabled = vim.g.rime_enabled,
				shared_data_dir = Utils.is_win() and "D:\\软件\\rime\\data" or "/usr/share/rime-data",
				user_data_dir = Utils.is_win() and [[D:\软件\rime\rime_ls_wanxiang]]
					or vim.fn.expand("~/.local/share/rime_ls_wanxiang"),
				log_dir = Utils.is_win() and "D:\\软件\\rime\\logs" or vim.fn.expand("~/.local/share/rime-ls/logs"),
				long_filter_text = true,
				schema_trigger_character = "&",
			},
		},
	},
	setup = {
		rime_ls = function(_, _)
			if vim.fn.executable("rime_ls") == 0 then
				Snacks.notify.warn("Rime LSP is not installed", { title = "Rime LSP" })
				return true
			end

			vim.g.rclone_sync_rime = false
			if Utils.is_remote() and vim.fn.executable("rclone") == 1 then
				vim.g.rclone_sync_rime = true
				vim.g.rclone_rime_remote_path = "od:webdav/rime"
				vim.g.rclone_rime_local_path = vim.fn.expand("~/rclone/rime")
			end

			Utils.rime.setup({
				filetype = vim.g.rime_ls_support_filetype,
			})
		end,
	},
}
return opts
