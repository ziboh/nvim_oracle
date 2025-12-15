vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("FiletypeSpecificTabs", { clear = true }),
	pattern = { "text" },
	callback = function()
		vim.bo.expandtab = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("AutoSetFileType", {}),
	pattern = "json",
	callback = function()
		local filepath = vim.fn.expand("%:p") -- 获取完整文件路径

		-- 排除名单 - 这些文件将使用标准 json filetype
		local exclude_patterns = {
			"/package%.json$", -- package.json
			"/tsconfig%.json$", -- TypeScript 配置
			"/composer%.json$", -- PHP composer
			"/bower%.json$", -- Bower 配置
			"%/schema%.json$", -- Schema 文件
			"/swagger%.json$", -- Swagger 配置
			"/openapi%.json$", -- OpenAPI 配置
		}

		-- 检查是否匹配排除模式
		for _, pattern in ipairs(exclude_patterns) do
			if string.match(filepath, pattern) then
				return
			end
		end

		-- 默认使用 jsonc
		vim.bo.filetype = "jsonc"
	end,
})

local group = vim.api.nvim_create_augroup("ChangeTitle", { clear = true })
vim.api.nvim_create_autocmd("TermEnter", {
	group = group,
	callback = function()
		vim.opt.titlestring = "terminal"
	end,
})

vim.api.nvim_create_autocmd("TermLeave", {
	group = group,
	callback = function()
		vim.opt.titlestring = "neovim"
	end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = group,
	pattern = "*",
	callback = function()
		vim.opt.titlestring = "command"
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = group,
	pattern = "*",
	callback = function()
		vim.opt.titlestring = "neovim"
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function(args)
		if vim.bo.filetype == "snacks_explorer_list" then
			vim.schedule(function()
				vim.opt.titlestring = "neovim-explorer"
			end)

			Utils.create_autocmd_once("BufLeave", {
				buffer = args.buf,
				group = group,
				callback = function()
					vim.opt.titlestring = "neovim"
				end,
			})
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "snacks_explorer_list",
	callback = function(args)
		vim.opt.titlestring = "neovim-explorer"
		Utils.create_autocmd_once("BufLeave", {
			buffer = args.buf,
			group = group,
			callback = function()
				vim.opt.titlestring = "neovim"
			end,
		})
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "autohotkey",
	callback = function()
		vim.bo.commentstring = "; %s"
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

local function apply_chezmoi_file()
	if vim.fn.executable("chezmoi") == 0 then
		return
	end
	local source_dir = vim.fn.trim(vim.fn.system("chezmoi source-path"))
	local buf_path = vim.api.nvim_buf_get_name(0)
	local rel_path = vim.fs.relpath(source_dir, vim.fn.fnamemodify(buf_path, ":p"))
	if buf_path == "" or not rel_path or rel_path:sub(1, 1) == "." then
		return
	end
	-- 转换路径
	rel_path = rel_path:gsub("^dot%_", "."):gsub("%.tmpl$", ""):gsub("/dot%.", "/.")
	local target_path = vim.fs.joinpath(vim.fn.expand("~"), rel_path)

	-- 异步应用
	vim.system({ "chezmoi", "apply", "--force", target_path }, { text = true }, function(result)
		if result.code == 0 then
			Snacks.notify("chezmoi apply --force " .. target_path, { title = "chezmoi" })
		else
			Snacks.notify.error("chezmoi apply error: " .. target_path, { title = "chezmoi" })
		end
	end)
end

-- 自动命令
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = apply_chezmoi_file,
})

Utils.create_autocmd_once("BufFilePost", {
	callback = function()
		vim.schedule(function()
			vim.opt.titlestring = ""
			vim.opt.titlestring = "neovim"
		end)
	end,
})

-- 存储缓冲区的 buflisted 状态
local saved_buflisted = {}

-- 格式化前保存 buflisted 状态
vim.api.nvim_create_autocmd("User", {
	pattern = "ConformFormatPre",
	callback = function(args)
		local bufnr = args.buf
		saved_buflisted[bufnr] = vim.bo[bufnr].buflisted
	end,
})

-- 格式化后恢复 buflisted 状态
vim.api.nvim_create_autocmd("User", {
	pattern = "ConformFormatPost",
	callback = function(args)
		local bufnr = args.buf
		-- HACK: 不使用 defer_fn 函数设置不生效
		vim.defer_fn(function()
			if saved_buflisted[bufnr] ~= nil then
				Snacks.util.bo(args.buf, { buflisted = saved_buflisted[bufnr] })
				saved_buflisted[bufnr] = nil
			end
		end, 0)
	end,
})
