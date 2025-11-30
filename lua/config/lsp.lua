vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

require("mason").setup()
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("SetupLSP", {}),
	callback = function(event)
		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

		-- [inlay hint]
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			vim.keymap.set("n", "<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, { buffer = event.buf, desc = "LSP: Toggle Inlay Hints" })
		end

		-- [folding]
		if client and client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		-- [keymaps]
		vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
		vim.keymap.set("n", "<leader>ld", function()
			vim.diagnostic.open_float()
		end, { desc = "Hover diagnostics" })
		vim.keymap.set("n", "gd", function()
			local params = vim.lsp.util.make_position_params(0, "utf-8")
			vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
				if not result or vim.tbl_isempty(result) then
					vim.notify("No definition found", vim.log.levels.INFO)
				else
					require("snacks").picker.lsp_definitions()
				end
			end)
		end, { buffer = event.buf, desc = "LSP: Goto Definition" })
		vim.keymap.set("n", "gD", function()
			local win = vim.api.nvim_get_current_win()
			local width = vim.api.nvim_win_get_width(win)
			local height = vim.api.nvim_win_get_height(win)

			-- Mimic tmux formula: 8 * width - 20 * height
			local value = 8 * width - 20 * height
			if value < 0 then
				vim.cmd("split") -- vertical space is more: horizontal split
			else
				vim.cmd("vsplit") -- horizontal space is more: vertical split
			end

			vim.lsp.buf.definition()
		end, { buffer = event.buf, desc = "LSP: Goto Definition (split)" })

		local function jump_to_current_function_start()
			local params = { textDocument = vim.lsp.util.make_text_document_params() }
			local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
			if not responses then
				return
			end

			local pos = vim.api.nvim_win_get_cursor(0)
			local line = pos[1] - 1

			local function find_symbol(symbols)
				for _, s in ipairs(symbols) do
					local range = s.range or (s.location and s.location.range)
					if range and line >= range.start.line and line <= range["end"].line then
						if s.children then
							local child = find_symbol(s.children)
							if child then
								return child
							end
						end
						return s
					end
				end
			end

			for _, resp in pairs(responses) do
				local sym = find_symbol(resp.result or {})
				if sym and sym.range then
					vim.api.nvim_win_set_cursor(0, { sym.range.start.line + 1, 0 })
					return
				end
			end
		end
		vim.keymap.set("n", "[f", jump_to_current_function_start, { desc = "Jump to start of current function" })
		local function jump_to_current_function_end()
			local params = { textDocument = vim.lsp.util.make_text_document_params() }
			local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
			if not responses then
				return
			end

			local pos = vim.api.nvim_win_get_cursor(0)
			local line = pos[1] - 1

			local function find_symbol(symbols)
				for _, s in ipairs(symbols) do
					local range = s.range or (s.location and s.location.range)
					if range and line >= range.start.line and line <= range["end"].line then
						if s.children then
							local child = find_symbol(s.children)
							if child then
								return child
							end
						end
						return s
					end
				end
			end

			for _, resp in pairs(responses) do
				local sym = find_symbol(resp.result or {})
				if sym and sym.range then
					-- jump to end of the symbol
					vim.api.nvim_win_set_cursor(0, { sym.range["end"].line + 1, 0 })
					return
				end
			end
		end
		vim.keymap.set("n", "]f", jump_to_current_function_end, { desc = "Jump to end of current function" })
	end,
})

-- 只检测用户手动配置的 LSP 配置
local function auto_enable_user_lsp_configs()
	-- 指定你的配置目录路径
	local config_path = vim.fn.stdpath("config")
	local lsp_dir = config_path .. "/lsp"
	local after_lsp_dir = config_path .. "/after/lsp"

	-- 收集所有找到的配置名
	local found_configs = {}

	-- 检查 lsp/ 目录下的文件
	if vim.fn.isdirectory(lsp_dir) == 1 then
		local files = vim.fn.glob(lsp_dir .. "/*.lua", false, true)
		for _, file in ipairs(files) do
			local config_name = vim.fn.fnamemodify(file, ":t:r")
			found_configs[config_name] = true
		end
	end

	-- 检查 after/lsp/ 目录下的文件
	if vim.fn.isdirectory(after_lsp_dir) == 1 then
		local files = vim.fn.glob(after_lsp_dir .. "/*.lua", false, true)
		for _, file in ipairs(files) do
			local config_name = vim.fn.fnamemodify(file, ":t:r")
			found_configs[config_name] = true
		end
	end

	-- 启用所有找到的配置（只启用未启用的）
	for config_name in pairs(found_configs) do
		if not vim.lsp.is_enabled(config_name) then
			vim.lsp.enable(config_name)
			Snacks.notify("Enabled user LSP config: " .. config_name)
		end
	end
end

vim.api.nvim_create_autocmd('BufEnter', {  
  callback = function()  
    -- 确保 snacks 插件已加载  
    if package.loaded['snacks'] then  
      auto_enable_user_lsp_configs()  
    end  
  end,  
  desc = 'Auto-enable LSP configs after snacks loads'  
})

-- vim.cmd([[set completeopt+=menuone,noselect,popup]])
