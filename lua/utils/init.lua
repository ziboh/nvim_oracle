--- @class UserUtils
--- @field icons utils.icons
--- @field rime utils.rime
--- @field mini utils.mini
local M = {}

_G.Utils = M
setmetatable(M, {
	__index = function(t, k)
		t[k] = require("utils." .. k)
		return t[k]
	end,
})

--- Checks if a value exists in a list
---@param value any The value to search for
---@param list any[] The list to search in
---@return boolean|nil True if the value is found, nil otherwise
function M.value_in_list(value, list)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
end

function M.is_remote()
	if vim.env.SSH_TTY ~= nil then
		return true
	else
		return false
	end
end

function M.is_win()
	return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

function M.is_linux()
	return vim.uv.os_uname().sysname:find("Linux") ~= nil
end

function M.is_wsl()
	if os.getenv("WSL_DISTRO_NAME") then
		return true
	else
		return false
	end
end

-- 判断某个插件是否启动
function M.has(name)
	local ok, plugins = pcall(vim.pack.get, { name })
	if not ok then
		return false -- 插件未安装或其他错误
	end
	return #plugins > 0 and plugins[1].active == true
end

-- 检查系统内存
function M.is_memory_less_than(gb)
	-- 默认值为 1GB
	gb = gb or 1

	-- 将 GB 转换为字节
	local threshold = gb * 1024 * 1024 * 1024

	-- 获取系统总内存
	local total_memory = vim.uv.get_total_memory()

	return total_memory < threshold
end

-- 检查可用内存
function M.is_available_memory_less_than(gb)
	gb = gb or 1
	local threshold = gb * 1024 * 1024 * 1024

	local available_memory = vim.uv.get_available_memory()

	return available_memory < threshold
end

--- 检查空闲内存是否小于指定阈值
--- @param gb number 阈值大小，单位为GB，默认为1GB
--- @return boolean 如果空闲内存小于阈值则返回true，否则返回false
function M.is_free_memory_less_than_1gb(gb)
	gb = gb or 1
	local threshold = gb * 1024 * 1024 * 1024

	local free_memory = vim.uv.get_free_memory()

	return free_memory < threshold
end

-- 转换 lazy.nvim keys 为通用 keyma
function M.setup_keymaps(keys, opts)
	opts = opts or { silent = true, noremap = true }
	local default_opts = vim.deepcopy(opts)

	for _, keymap in ipairs(keys) do
		local lhs = keymap[1]
		local rhs = keymap[2]
		local keymap_opts = vim.tbl_deep_extend("force", default_opts, {})

		-- 复制键映射特定选项
		for k, v in pairs(keymap) do
			if type(k) ~= "number" then
				keymap_opts[k] = v
			end
		end

		-- 提取 mode 并从选项中移除
		local mode = keymap_opts.mode or "n"
		keymap_opts.mode = nil

		vim.keymap.set(mode, lhs, rhs, keymap_opts)
	end
end

function M.get_visual_selection()
	-- 检查是否在可视模式
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		return nil
	end

	-- 获取开始和结束位置
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	-- 行和列是从1开始计数的
	local start_line, start_col = start_pos[2], start_pos[3]
	local end_line, end_col = end_pos[2], end_pos[3]

	-- 确保开始位置在结束位置之前
	if start_line > end_line then
		start_line, end_line = end_line, start_line
		start_col, end_col = end_col, start_col
	end

	return {
		start_line = start_line,
		start_col = start_col,
		end_line = end_line,
		end_col = end_col,
		mode = mode, -- 添加模式信息
	}
end

function M.GetVisualSelection()
	vim.api.nvim_input("<Esc>")
	local pos = M.get_visual_selection()

	if pos == nil then
		return
	end

	-- 获取选中的行
	local start_line = pos.start_line
	local end_line = pos.end_line
	local lines = {}

	if pos.mode == "V" then
		-- 行可视模式：直接获取整行
		for line_num = start_line, end_line do
			local line = vim.fn.getline(line_num)
			table.insert(lines, line)
		end
	else
		-- 字符可视模式和块可视模式
		for line_num = start_line, end_line do
			local line = vim.fn.getline(line_num)

			-- 计算开始和结束的列位置
			local start_col = line_num == start_line and pos.start_col or 1
			local end_col = line_num == end_line and pos.end_col or #line

			-- 将列位置转换为字节索引
			local start_byte = vim.fn.byteidx(line, start_col - 1) + 1
			local end_byte = vim.fn.byteidx(line, end_col)

			-- 如果end_byte为nil（发生在行尾），使用字符串长度
			end_byte = end_byte or #line

			-- 提取这一行选中的部分
			local selected_text = string.sub(line, start_byte, end_byte)
			table.insert(lines, selected_text)
		end
	end

	-- 将所有行组合成一个字符串
	return table.concat(lines, "\n")
end

-- Determine if the character is a Chinese character
function M.detect_language(str)
	local chinese_count = 0
	local english_count = 0

	local i = 1
	while i <= #str do
		local byte = string.byte(str, i)
		if byte == nil then
			break
		end

		if byte >= 0xE0 and byte <= 0xEF then
			-- 中文字符（UTF-8 编码占3字节）
			chinese_count = chinese_count + 1
			i = i + 3
		elseif byte >= 0x20 and byte <= 0x7E then
			-- ASCII 可显示字符（英文、数字、符号等）
			english_count = english_count + 1
			i = i + 1
		else
			-- 其他字符
			i = i + 1
		end
	end

	return chinese_count > english_count and "Chinese" or "English"
end

--- 将 Lua table 转换为字符串表示形式
--- @param t table 要转换的 table
--- @param indent? string 可选参数，用于控制缩进（默认为空字符串）
--- @param visited? table 可选参数，用于记录已处理的 table，避免循环引用
--- @return string 返回 table 的字符串表示形式
function M.tableToString(t, indent, visited)
	-- 初始化缩进和已访问表
	indent = indent or ""
	visited = visited or {}
	-- 如果已经访问过这个表，直接返回
	if visited[t] then
		return indent .. "{...}"
	end

	-- 标记当前表为已访问
	visited[t] = true

	-- 开始构建字符串
	local result = indent .. "{\n"
	local newIndent = indent .. "  "

	-- 遍历表中的每个键值对
	for k, v in pairs(t) do
		-- 处理键
		local keyStr
		if type(k) == "string" then
			keyStr = '["' .. k .. '"]'
		else
			keyStr = "[" .. tostring(k) .. "]"
		end

		-- 处理值
		local valueStr
		if type(v) == "table" then
			valueStr = M.tableToString(v, newIndent, visited)
		elseif type(v) == "string" then
			valueStr = '"' .. v .. '"'
		else
			valueStr = tostring(v)
		end

		-- 将键值对添加到结果中
		result = result .. newIndent .. keyStr .. " = " .. valueStr .. ",\n"
	end

	-- 结束构建字符串
	result = result .. indent .. "}"
	return result
end

--- 将 Lua table 转换为字符串表示形式
--- @param t table 要转换的 table
--- @param indent? string 可选参数，用于控制缩进（默认为空字符串）
--- @param visited? table 可选参数，用于记录已处理的 table，避免循环引用
function M.PrintTable(t, indent, visited)
	vim.notify(M.tableToString(t, indent, visited))
end

function M.is_port_in_use(port)
	local command
	local os_name = vim.loop.os_uname().sysname

	-- 根据操作系统选择不同的命令
	if os_name == "Linux" then
		-- 只查找 LISTEN 状态的端口，使用更精确的匹配
		command = string.format("ss -tuln state listening | grep ':\\b%d\\b'", port)
	elseif os_name == "Windows_NT" then
		-- 在 Windows 下专门查找 LISTENING 状态的端口
		command = string.format('netstat -an | findstr /R /C:":%d.*LISTENING"', port)
	else
		print("Unsupported operating system")
		return false
	end

	-- 执行命令并获取输出
	local handle = io.popen(command)
	if not handle then
		print("Failed to execute command")
		return false
	end

	local result = handle:read("*a")
	local success, _ = handle:close()

	if not success then
		print("Failed to close handle")
		return false
	end

	-- 判断输出是否包含端口信息
	return result and result:match("%S") ~= nil
end

-- 创建一个函数来关闭指定端口的进程
function M.win_close_port(port)
	-- 获取占用端口的进程信息
	local handle = io.popen(string.format("netstat -ano | findstr :%d", port))
	local result = ""
	if handle ~= nil then
		result = handle:read("*a")
		handle:close()
	end

	-- 如果没有找到进程
	if result == "" then
		print("No process found using port " .. port)
		return
	end

	-- 从结果中提取 PID
	-- netstat 输出格式类似：TCP    0.0.0.0:9928    0.0.0.0:0    LISTENING    1234
	local pid = result:match("%d+%s*$"):gsub("%s+", "")

	if pid then
		-- 使用 taskkill 命令关闭进程
		local cmd = string.format("taskkill /PID %s /F", pid)
		local kill_handle = io.popen(cmd)
		if kill_handle ~= nil then
			local kill_result = kill_handle:read("*a"):gsub("%s+$", "")
			kill_handle:close()
			Snacks.notify(kill_result)
		end
	else
		print("Could not find PID for port " .. port)
	end
end

--- @param keys string
--- @param mode string
function M.feedkeys(keys, mode)
	-- 将按键序列转换为 Neovim 内部格式
	local termcodes = vim.api.nvim_replace_termcodes(keys, true, true, true)
	-- Send the converted key sequence to Neovim's input buffer.
	vim.api.nvim_feedkeys(termcodes, mode, false)
end

--- 创建一次性自动命令
--- 此函数是对 `vim.api.nvim_create_autocmd` 的封装，强制设置 `once = true`，
--- 确保自动命令在触发一次后自动删除，避免重复执行。
---
--- @param event vim.api.keyset.events|vim.api.keyset.events[] 触发处理程序的事件或事件列表（`callback` 或 `command`）。
--- @param opts vim.api.keyset.create_autocmd 选项字典：
--- @return integer 返回创建的自动命令ID，可用于后续删除（如 `nvim_del_autocmd`）
function M.create_autocmd_once(event, opts)
	-- 确保 opts 是一个 table
	opts = opts or {}

	-- 设置 once = true
	opts.once = true

	-- 调用原始函数
	return vim.api.nvim_create_autocmd(event, opts)
end

---@param on_attach fun(client:vim.lsp.Client, buffer)
---@param name? string
function M.on_attach(on_attach, name)
	return vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf ---@type number
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and (not name or client.name == name) then
				return on_attach(client, buffer)
			end
		end,
	})
end

return M
