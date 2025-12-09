--- Use Rclone to sync with remote storage
---@param src string Local file path
---@param dst string Remote file path
---@param callback? fun(success:boolean)
local rclone_sync = function(src, dst, callback)
	if vim.fn.executable("rclone") == 0 then
		Snacks.notify.error("rclone 未安装，请先安装 rclone")
		if callback then
			callback(false)
		end
	end
	local rclone_cmd = "rclone sync " .. src .. " " .. dst
	vim.fn.jobstart(rclone_cmd, {
		on_exit = function(_, rclone_exit_code)
			if rclone_exit_code == 0 then
				if callback then
					callback(true)
				end
			else
				Snacks.notify.error("rclone 同步失败")
				if callback then
					callback(false)
				end
			end
		end,
	})
end

-- Return if rime_ls should be disabled in current context
local rime_ls_disabled = function(context)
	local line = context.line
	local cursor_column = context.cursor[2]
	for _, pattern in ipairs(vim.g.disable_rime_ls_pattern) do
		local start_pos = 1
		while true do
			local match_start, match_end = string.find(line, pattern, start_pos)
			if not match_start then
				break
			end
			if cursor_column >= match_start and cursor_column < match_end then
				return true
			end
			start_pos = match_end + 1
		end
	end
	return false
end

local rime_on_attach = function(client, _)
	local mapped_punc = {
		[","] = "，",
		["."] = "。",
		[":"] = "：",
		["?"] = "？",
		["\\"] = "、",
		[";"] = "；",
	}
	local feedkeys = Utils.feedkeys

	local map_set = vim.keymap.set
	local map_del = vim.keymap.del

	local sync_user_data = function()
		client:request("workspace/executeCommand", { command = "rime-ls.sync-user-data" }, function(err, result)
			if result == nil and not err then
				Snacks.notify("Rime LSP: sync user data success", { title = "Rime LSP" })
			else
				Snacks.notify.warn("Rime LSP: sync user data failed", { title = "Rime LSP" })
			end
		end)
	end

	vim.api.nvim_create_user_command("RimeSync", function()
		if not vim.g.rclone_sync_rime then
			sync_user_data()
		else
			vim.schedule(function()
				rclone_sync(vim.g.rclone_rime_remote_path, vim.g.rclone_rime_local_path, function(success)
					if success then
						sync_user_data()
						vim.schedule(function()
							rclone_sync(vim.g.rclone_rime_local_path, vim.g.rclone_rime_remote_path)
						end)
					end
				end)
			end)
		end
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("RimeToggle", function()
		client:request("workspace/executeCommand", { command = "rime-ls.toggle-rime" }, function(_, result, ctx)
			if vim.g.rime_enabled then
				for k, _ in pairs(mapped_punc) do
					map_del({ "i" }, k .. "<space>")
				end
			else
				for k, v in pairs(mapped_punc) do
					map_set({ "i" }, k .. "<space>", function()
						if
							rime_ls_disabled({
								line = vim.api.nvim_get_current_line(),
								cursor = vim.api.nvim_win_get_cursor(0),
							})
						then
							feedkeys(k .. "<space>", "n")
						else
							feedkeys(v, "n")
						end
					end)
				end
			end
			if ctx.client_id == client.id then
				vim.g.rime_enabled = result
				if result then
					Snacks.notify("Rime Enabled", { title = "Rime", timeout = 3000 })
				else
					Snacks.notify.warn("Rime Disabled", { title = "Rime", timeout = 3000 })
				end
			end
		end)
	end, { nargs = 0 })
	-- Toggle rime
	-- This will toggle Chinese punctuations too
	map_set({ "n", "i" }, "<C-M-f12>", function()
		-- We must check the status before the toggle
		vim.cmd("RimeToggle")
	end)
end

local opts = {
	servers = {
		rime_ls = {
			offset_encoding = "utf-8",
			on_attach = rime_on_attach,
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
			if vim.fn.executable("rime_ls") ~= 1 then
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
