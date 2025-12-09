local install_ahk2_lsp = function(callback)
	-- 获取数据目录路径
	local install_dir = vim.fn.stdpath("data") .. "/vscode-autohotkey2-lsp"

	-- 创建安装目录
	vim.fn.mkdir(install_dir, "p")

	-- 保存当前目录
	local current_dir = vim.fn.getcwd()
	vim.fn.chdir(install_dir)

	-- 下载安装脚本
	local install_script = install_dir .. "/install.js"
	local download_cmd = {
		"curl.exe",
		"-L",
		"-o",
		install_script,
		"https://raw.githubusercontent.com/thqby/vscode-autohotkey2-lsp/main/tools/install.js",
	}

	-- 异步执行下载
	vim.fn.jobstart(download_cmd, {
		on_exit = function(_, code)
			if code ~= 0 then
				vim.schedule(function()
					Snacks.notify.error("Failed to download install script")
					vim.fn.chdir(current_dir)
					if callback then
						callback(false)
					end
				end)
				return
			end

			-- 异步执行安装脚本
			vim.fn.chdir(install_dir)
			vim.fn.jobstart({ "node", "install.js" }, {
				on_exit = function(_, install_code)
					vim.schedule(function()
						vim.fn.chdir(current_dir)
						if install_code == 0 then
							Snacks.notify.info("AutoHotkey 2 LSP installed successfully!")
							if callback then
								callback(true)
							end
						else
							Snacks.notify.error("Failed to run install script")
							if callback then
								callback(false)
							end
						end
					end)
				end,
			})
		end,
	})
end

local opts = {
	servers = {
		autohotkey_lsp = {
			enabled = Utils.is_win(),
			cmd = {
				"node",
				vim.fn.expand(vim.fn.stdpath("data") .. "/vscode-autohotkey2-lsp/server/dist/server.js"),
				"--stdio",
			},
			init_options = {
				locale = "zh-cn",
			},
		},
	},
	setup = {
		autohotkey_lsp = function(_, opts)
			local server_path = vim.fn.expand(vim.fn.stdpath("data") .. "/vscode-autohotkey2-lsp/server/dist/server.js")
			if vim.fn.filereadable(server_path) == 1 then
				return
			else
				vim.schedule(function()
					Snacks.notify.info("Installing AutoHotkey language server...")
					install_ahk2_lsp(function(success)
						if success then
							vim.schedule(function()
								vim.lsp.config("autohotkey_lsp", opts)
								if vim.bo.filetype == "autohotkey" or vim.bo.filetype == "ahk" then
									vim.cmd("LspStart autohotkey_lsp")
								end
							end)
						end
					end)
				end)
				return true
			end
		end,
	},
}
return opts
