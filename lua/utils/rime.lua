local function contains_unacceptable_character(content)
	if content == nil then
		return true
	end
	local ignored_head_number = false
	for i = 1, #content do
		local b = string.byte(content, i)
		if b >= 48 and b <= 57 or b == 32 or b == 46 then
			-- number dot and space
			if ignored_head_number then
				return true
			end
		elseif b <= 127 then
			return true
		else
			ignored_head_number = true
		end
	end
	return false
end

---@class utils.rime
local M = {}

-- Return if rime_ls should be disabled in current context
function M.rime_ls_disabled(context)
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

function M.is_rime_item(item)
	if item == nil or item.source_name ~= "rime_ls" then
		return false
	end
	local client = vim.lsp.get_client_by_id(item.client_id)
	return client ~= nil and client.name == "rime_ls"
end

function M.rime_item_acceptable(item)
	return not contains_unacceptable_character(item.label) or item.label:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d%")
end

function M.get_n_rime_item_index(n, items)
	if items == nil then
		items = require("blink.cmp.completion.list").items
	end
	local result = {}
	if items == nil or #items == 0 then
		return result
	end
	for i, item in ipairs(items) do
		if M.is_rime_item(item) then
			result[#result + 1] = i
			if #result == n then
				break
			end
		end
	end
	return result
end

--- @class RimeSetupOpts
--- @field filetype string|string[]

--- @param opts? RimeSetupOpts
function M.setup(opts)
	opts = opts or {}
	local filetypes = (opts and opts.filetype) and opts.filetype or nil
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end
	local port = Utils.is_win() and 9528 or 9527
	local rime_started = false

	if not Utils.is_port_in_use(port) then
		vim.system({ "rime_ls", "--listen", "127.0.0.1:" .. port }, { detach = true })

		-- 等待 rime_ls 启动，最多等待 5 秒
		local max_attempts = 50 -- 5秒 = 50次 * 100毫秒
		local attempt = 0

		while attempt < max_attempts and not Utils.is_port_in_use(port) do
			vim.wait(100) -- 等待 100 毫秒
			attempt = attempt + 1
		end

		if Utils.is_port_in_use(port) then
			rime_started = true
		else
			vim.notify("rime_ls 启动超时，请检查是否已正确安装", vim.log.levels.WARN)
		end
	else
		rime_started = true
	end

	if rime_started then
		vim.lsp.config.rime_ls = {
			name = "rime_ls",
			cmd = vim.lsp.rpc.connect("127.0.0.1", port),
			filetypes = filetypes,
			single_file_support = true,
		}
	else
		vim.notify("未能启动 rime_ls，跳过 LSP 配置", vim.log.levels.WARN)
	end
	Utils.create_autocmd_once("User", {
		pattern = "BlinkLoaded",
		callback = function()
			require("blink.cmp.completion.list").show_emitter:on(function(event)
				if not vim.g.rime_enabled then
					return
				end
				local col = vim.fn.col(".") - 1
				if event.context.line:sub(col, col):match("%d") == nil then
					return
				end

				local rime_item_index = Utils.rime.get_n_rime_item_index(2, event.items)

				if #rime_item_index ~= 1 then
					return
				end

				vim.schedule(function()
					require("blink.cmp").accept({ index = rime_item_index[1] })
				end)
			end)
		end,
	})
end

--- Use Rclone to sync with remote storage
---@param src string Local file path
---@param dst string Remote file path
---@param callback? fun(success:boolean)
function M.rclone_sync(src, dst, callback)
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

function M.rime_on_attach(client, _)
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
				M.rclone_sync(vim.g.rclone_rime_remote_path, vim.g.rclone_rime_local_path, function(success)
					if success then
						sync_user_data()
						vim.schedule(function()
							M.rclone_sync(vim.g.rclone_rime_local_path, vim.g.rclone_rime_remote_path)
						end)
					end
				end)
			end)
		end
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("RimeToggle", function()
		client:request("workspace/executeCommand", { command = "rime-ls.toggle-rime" }, function()
			if vim.g.rime_enabled then
				for k, _ in pairs(mapped_punc) do
					map_del({ "i" }, k .. "<space>")
				end
			else
				for k, v in pairs(mapped_punc) do
					map_set({ "i" }, k .. "<space>", function()
						if
							M.rime_ls_disabled({
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
			vim.g.rime_enabled = not vim.g.rime_enabled
		end)
	end, { nargs = 0 })

	Snacks.toggle
		.new({
			id = "rime",
			name = "Rime",
			get = function()
				return vim.g.rime_enabled
			end,
			set = function(enabled)
				if enabled ~= vim.g.rime_enabled then
					vim.cmd("RimeToggle")
				end
			end,
		})
		:map("<C-M-F12>", { mode = { "n", "i" } })
end

return M
