vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
})

require("mason").setup()
local automatic_enable = { "nushell", "lua_ls" }
local diagnostics = {
	virtual_text = {
		spacing = 4,
		source = "if_many",
		-- prefix = "●",
		-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
		prefix = "icons",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = Utils.icons.diagnostics.Error,
			[vim.diagnostic.severity.HINT] = Utils.icons.diagnostics.Hint,
			[vim.diagnostic.severity.WARN] = Utils.icons.diagnostics.Warn,
			[vim.diagnostic.severity.INFO] = Utils.icons.diagnostics.Info,
		},
	},
}

diagnostics.virtual_text.prefix = function(diagnostic)
	local icons = Utils.icons.diagnostics
	for d, icon in pairs(icons) do
		if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
			return icon
		end
	end
	return "●"
end

vim.diagnostic.config(diagnostics)
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { remap = true, desc = "Mason" })

if not Utils.is_memory_less_than() then
	vim.pack.add({
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	})

	vim.keymap.set("n", "<leader>ll", function()
		Snacks.picker.lsp_config()
	end, { desc = "Lsp Info", silent = true, noremap = true })
	require("mason-lspconfig").setup({
		ensure_installed = { "lua_ls", "stylua" },
		automatic_enable = {
			exclude = { "stylua" },
		},
	})
	local keys = {
		{
			"<leader>ll",
			function()
				Snacks.picker.lsp_config()
			end,
			desc = "Lsp Info",
		},
		{
			"gd",
			vim.lsp.buf.definition,
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
				return vim.lsp.buf.hover()
			end,
			desc = "Hover",
		},
		{
			"K",
			function()
				return vim.lsp.buf.hover()
			end,
			desc = "Hover",
		},
		{
			"<leader>lh",
			function()
				return vim.lsp.buf.signature_help()
			end,
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{
			"<c-k>",
			function()
				return vim.lsp.buf.signature_help()
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
	}

	-- 创建 LspAttach 自动命令处理 Keymap
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client then
				return
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
					local opts = {
						buffer = args.buf,
						desc = keymap.desc,
						nowait = keymap.nowait,
					}
					vim.keymap.set(keymap.mode or "n", keymap[1], keymap[2], opts)
				end
			end
		end,
	})
	for _, lsp in ipairs(automatic_enable) do
		vim.lsp.enable(lsp)
	end
end
