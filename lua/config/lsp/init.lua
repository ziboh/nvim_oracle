vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
})

if not Utils.is_memory_less_than() then
	vim.pack.add({
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
		"https://github.com/mrcjkb/rustaceanvim",
		"https://github.com/saecki/crates.nvim",
	})
end

vim.g.mason_opts = {
	github = {
		download_url_template = "https://ghfast.top/https://github.com/%s/releases/download/%s/%s",
	},
	ensure_installed = {
		"stylua",
		"shfmt",
	},
}

if Utils.is_linux() then
	Utils.mason_add_ensure_installed("bacon")
end

Utils.create_autocmd_once("User", {
	pattern = "ConfigLoaded",
	callback = function()
		local mr = require("mason-registry")
		mr:on("package:install:success", function()
			vim.defer_fn(function()
				-- trigger FileType event to possibly load this newly installed LSP server
				vim.api.nvim_exec_autocmds("FileType", { buffer = vim.api.nvim_get_current_buf() })
			end, 100)
		end)

		mr.refresh(function()
			for _, tool in ipairs(vim.g.mason_opts.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
		end)
		vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { remap = true, desc = "Mason" })
	end,
})
require("mason").setup(vim.g.mason_opts)

local lsp_loaded = false
Utils.create_autocmd_once({ "BufReadPre", "FileType", "BufNewFile" }, {
	callback = function()
		if Utils.is_memory_less_than() or lsp_loaded then
			return
		end
		lsp_loaded = true
		local opts = {
			servers = {
				-- configuration for all lsp servers
				["*"] = {
					capabilities = {
						textDocument = {
							completion = {
								completionItem = {
									commitCharactersSupport = true,
								},
							},
						},
					},
					keys = {
						{
							"gd",
							function()
								Snacks.picker.lsp_definitions()
							end,
							desc = "Goto Definition",
							has = "definition",
						},
						{
							"gr",
							vim.lsp.buf.references,
							desc = "References",
							nowait = true,
						},
						{ "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
						{ "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
						{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
						{
							"<leader>h",
							function()
								vim.lsp.buf.hover({ silent = true })
							end,
							desc = "Hover",
						},
						{
							"K",
							function()
								vim.lsp.buf.hover({ silent = true })
							end,
							desc = "Hover",
						},
						{
							"<leader>lh",
							function()
								vim.lsp.buf.signature_help()
							end,
							desc = "Signature Help",
							has = "signatureHelp",
						},
						{
							"<c-k>",
							function()
								vim.lsp.buf.signature_help()
							end,
							mode = "i",
							desc = "Signature Help",
							has = "signatureHelp",
						},
						{
							"<leader>la",
							vim.lsp.buf.code_action,
							desc = "Code Action",
							mode = { "n", "v" },
							has = "codeAction",
						},
						{
							"<leader>lc",
							vim.lsp.codelens.run,
							desc = "Run Codelens",
							mode = { "n", "v" },
							has = "codeLens",
						},
						{
							"<leader>lC",
							vim.lsp.codelens.refresh,
							desc = "Refresh & Display Codelens",
							mode = { "n" },
							has = "codeLens",
						},

						{
							"<leader>ss",
							function()
								Snacks.picker.lsp_symbols()
							end,
							mode = { "n", "v" },
							desc = "LSP Symbols",
							has = "documentSymbol",
						},
						{
							"<leader>sS",
							function()
								Snacks.picker.lsp_workspace_symbols()
							end,
							mode = { "n", "v" },
							desc = "workspace/symbol",
						},
						{
							"<leader>lR",
							function()
								Snacks.rename.rename_file()
							end,
							desc = "Rename File",
							mode = { "n" },
							has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
						},
						{
							"<leader>lr",
							vim.lsp.buf.rename,
							desc = "Rename",
							has = "rename",
						},
						{
							"]]",
							function()
								Snacks.words.jump(vim.v.count1)
							end,
							has = "documentHighlight",
							desc = "Next Reference",
							cond = function()
								return Snacks.words.is_enabled()
							end,
						},
						{
							"[[",
							function()
								Snacks.words.jump(-vim.v.count1)
							end,
							has = "documentHighlight",
							desc = "Prev Reference",
							cond = function()
								return Snacks.words.is_enabled()
							end,
						},
					},
				},
				lua_ls = {},
				bashls = {
					mason = true,
					filetypes = { "sh", "bash" },
				},
				nushell = {},
				eslint = {
					settings = {
						-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
						workingDirectories = { mode = "auto" },
					},
				},
				stylua = {
					enabled = false,
				},
				copolit = {},
			},
			setup = {},
		}

		local lspconfig_path = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/config/lsp")
		local lsp_config_filename = vim.fn.readdir(lspconfig_path)
		vim.tbl_map(function(file)
			if file ~= "init.lua" and file:match("%.lua$") then
				local filename = file:gsub("%.lua$", "")
				local lsp_opts = require("config.lsp." .. filename)
				if lsp_opts ~= true then
					opts = vim.tbl_deep_extend("force", opts, lsp_opts)
				end
			end
		end, lsp_config_filename)

		vim.keymap.set("n", "<leader>ll", function()
			Snacks.picker.lsp_config()
		end, { desc = "Lsp Info", silent = true, noremap = true })

		if opts.servers["*"] then
			vim.lsp.config("*", opts.servers["*"])
		end

		-- get all the servers that are available through mason-lspconfig
		local have_mason = Utils.has("mason-lspconfig.nvim")
		local mason_all = have_mason
				and vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
			or {} --[[ @as string[] ]]
		local mason_exclude = {} ---@type string[]

		---@return boolean? exclude automatic setup
		local function configure(server)
			if server == "*" then
				return false
			end
			local sopts = opts.servers[server]
			sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

			---@diagnostic disable-next-line: undefined-field
			if sopts.enabled == false then
				mason_exclude[#mason_exclude + 1] = server
				return
			end

			---@diagnostic disable-next-line: undefined-field
			local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
			local setup = opts.setup[server] or opts.setup["*"]
			if setup and setup(server, sopts) then
				mason_exclude[#mason_exclude + 1] = server
			else
				vim.lsp.config(server, sopts) -- configure the server
				if not use_mason then
					vim.lsp.enable(server)
				end
			end
			return use_mason
		end

		local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
		if have_mason then
			require("mason-lspconfig").setup({
				ensure_installed = install,
				automatic_enable = { exclude = mason_exclude },
			})
		end

		-- 创建 LspAttach 自动命令处理 Keymap
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end
				local keys = opts.servers["*"].keys
				for server, server_opts in pairs(opts.servers) do
					if type(server_opts) == "table" and server_opts.keys and client.name == server then
						keys = vim.list_extend(keys, server_opts.keys)
					end
				end
				-- 遍历所有 keymap 配置
				for _, keymap in ipairs(keys) do
					-- 检查 has 字段
					local has_method = true
					if keymap.has then
						if type(keymap.has) == "string" then
							has_method = client:supports_method("textDocument/" .. keymap.has)
						elseif type(keymap.has) == "table" then
							has_method = vim.iter(keymap.has):any(function(method)
								return client:supports_method(method)
							end)
						end
					end

					-- 检查 cond 字段
					local cond_ok = true
					if keymap.cond then
						cond_ok = keymap.cond()
					end

					-- 如果满足条件，则设置 keymap
					if has_method and cond_ok then
						local sopts = {
							buffer = args.buf,
							desc = keymap.desc,
							nowait = keymap.nowait,
						}
						vim.keymap.set(keymap.mode or "n", keymap[1], keymap[2], sopts)
					end
				end
			end,
		})
	end,
})
