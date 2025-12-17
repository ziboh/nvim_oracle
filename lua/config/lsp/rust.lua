local diagnostics = "rust-analyzer" -- rust-analyzer 或 bacon-ls
if Utils.is_linux() then
	diagnostics = "bacon-ls"
end

local rust_opts = {
	server = {
		offset_encoding = "utf-8",
		default_settings = {
			-- rust-analyzer language server configuration
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
					loadOutDirsFromCheck = true,
					buildScripts = {
						enable = true,
					},
				},
				-- Add clippy lints for Rust if using rust-analyzer
				checkOnSave = diagnostics == "rust-analyzer",
				-- Enable diagnostics if using rust-analyzer
				diagnostics = {
					enable = diagnostics == "rust-analyzer",
				},
				procMacro = {
					enable = true,
					ignored = {
						["async-trait"] = { "async_trait" },
						["napi-derive"] = { "napi" },
						["async-recursion"] = { "async_recursion" },
					},
				},
				files = {
					excludeDirs = {
						".direnv",
						".git",
						".github",
						".gitlab",
						"bin",
						"node_modules",
						"target",
						"venv",
						".venv",
					},
				},
			},
		},
	},
	status_notify_level = false,
}
local capabilities = require("rustaceanvim.config.server").create_client_capabilities()
capabilities.general.positionEncodings = { "utf-8", "utf-16" }
rust_opts.server.capabilities = capabilities
vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, rust_opts or {})
if vim.fn.executable("rust-analyzer") == 0 then
	Snacks.notify.error(
		"**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
		{ title = "rustaceanvim" }
	)
end

local filepath = vim.api.nvim_buf_get_name(0)
local basename = vim.fn.fnamemodify(filepath, ":t")
local crates_loaded = false
if basename == "Cargo.toml" then
	require("crates").setup({
		lsp = {
			enabled = true,
			actions = true,
			completion = true,
			hover = true,
		},
	})
	crates_loaded = true
end

Utils.create_autocmd_once("BufReadPre", {
	pattern = "Cargo.toml",
	callback = function()
		if crates_loaded == true then
			return
		end
		require("crates").setup({
			lsp = {
				enabled = true,
				actions = true,
				completion = true,
				hover = true,
			},
		})
	end,
})

return {
	servers = {
		bacon_ls = {
			enabled = diagnostics == "bacon-ls",
		},
		rust_analyzer = {
			enabled = false,
			keys = {
				{
					"<leader>la",
					function()
						vim.cmd.RustLsp("codeAction")
					end,
					desc = "Code Action",
				},
				{
					"K",
					function()
						vim.cmd.RustLsp({ "hover", "actions" })
					end,
					desc = "Hover",
				},
			},
		},
		["crates.nvim"] = {
			keys = {
				{
					"<leader>h",
					function()
						local filetype = vim.bo.filetype
						if filetype == "vim" or filetype == "help" then
							vim.cmd("h " .. vim.fn.expand("<cword>"))
						elseif filetype == "man" then
							vim.cmd("Man " .. vim.fn.expand("<cword>"))
						elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
							require("crates").show_popup()
						else
							vim.lsp.buf.hover()
						end
					end,
					desc = "Hover",
				},
				{
					"K",
					function()
						local filetype = vim.bo.filetype
						if filetype == "vim" or filetype == "help" then
							vim.cmd("h " .. vim.fn.expand("<cword>"))
						elseif filetype == "man" then
							vim.cmd("Man " .. vim.fn.expand("<cword>"))
						elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
							require("crates").show_popup()
						else
							vim.lsp.buf.hover()
						end
					end,
					desc = "Hover",
				},
			},
		},
	},
}
