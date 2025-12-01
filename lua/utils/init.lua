--- @class UserUtils
--- @field icons utils.icons
--- @field lsp utils.lsp
local M = {}

setmetatable(M, {
	__index = function(t, k)
		t[k] = require("utils." .. k)
		return t[k]
	end,
})

function M.is_remote()
	if vim.env.SSH_TTY ~= nil or (vim.env.WEZTERM_EXECUTABLE ~= nil and vim.env.XDG_RUNTIME_DIR ~= nil) then
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

-- 检查空闲内存
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

return M
