vim.pack.add({
	{ src = "https://github.com/folke/snacks.nvim" },
})

local function term_nav(dir)
	---@param self snacks.terminal
	return function(self)
		return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
			vim.cmd.wincmd(dir)
		end)
	end
end

local opts = {
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	picker = {
		matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
		formatters = { icon_width = 3 },
		actions = {
			edit_popup = function(picker, item)
				picker:close()
				Snacks.win({
					file = item._path,
					width = 100,
					height = 30,
					bo = {
						buftype = "",
						buflisted = false,
						bufhidden = "hide",
						swapfile = false,
						modifiable = true,
					},
					minimal = false,
					noautocmd = false,
					zindex = 20,
					wo = {
						winhighlight = "NormalFloat:Normal",
					},
					border = "rounded",
					title_pos = "center",
					footer_pos = "center",
				})
				-- HACK: this should fix folds
				if vim.wo.foldmethod == "expr" then
					vim.schedule(function()
						vim.opt.foldmethod = "expr"
					end)
				end
			end,
			edit_vsplit = function(picker, item)
				picker:close()
				Snacks.win({
					file = item._path,
					position = "right",
					width = 0.5,
					minimal = false,
					wo = {
						winhighlight = "NormalFloat:Normal",
					},
					bo = {
						modifiable = true,
					},
				})

				-- HACK: this should fix folds
				if vim.wo.foldmethod == "expr" then
					vim.schedule(function()
						vim.opt.foldmethod = "expr"
					end)
				end
			end,
			---@param picker snacks.Picker
			clear_input = function(picker)
				vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, {})
			end,
			delect_file = function(picker)
				local options = { "Yes", "No" }
				vim.ui.select(options, {}, function(choice)
					if choice == "Yes" then
						local items = picker:selected({ fallback = true })
						for _, item in ipairs(items) do
							local path = item._path
							local ok, err = pcall(vim.fn.delete, path, "rf")
							if ok then
								Snacks.bufdelete({ file = path, force = true })
							else
								Snacks.notify.error("Failed to delete `" .. path .. "`:\n- " .. err)
							end
							picker:close()
						end
						Snacks.picker.resume()
					end
				end)
			end,
			tcd_cwd = function(_, item)
				vim.cmd.tcd(item.cwd)
			end,
			tcd_root = function(_, item)
				vim.cmd.tcd(vim.fs.root(item._path, ".git"))
			end,
		},
		on_show = function(picker)
			local input = picker.input.win
			if input then
				input:on("InsertEnter", function()
					vim.opt.titlestring = "input"
					-- The title you set will not take effect immediately; you need to manually execute redraw.
					vim.cmd("redraw")
				end)
				input:on("InsertLeave", function()
					vim.opt.titlestring = "neovim"
				end)
			end
		end,
		win = {
			input = {
				keys = {
					["<c-p>"] = { "select_and_prev", mode = { "i", "n" } },
					["<c-n>"] = { "select_and_next", mode = { "i", "n" } },
					["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
					["<Tab>"] = { "list_down", mode = { "i", "n" } },
					["<c-l>"] = { "clear_input", mode = { "n", "i" } },
					["<c-f>"] = { "edit_popup", mode = { "n", "i" } },
				},
			},
		},
	},
	dashboard = {
		preset = {
			---@type snacks.dashboard.Item[]
			keys = {
				{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{
					icon = " ",
					key = "c",
					desc = "Config",
					action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config'), confirm = { 'tcd_cwd', 'jump' } })",
				},
				{
					icon = " ",
					key = "p",
					desc = "Projects",
					action = ":lua Snacks.picker.projects()",
				},
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
		},
	},
	explorer = {
		replace_netrw = true, -- Replace netrw with the snacks explorer
	},
	image = {
		enabled = true,
		doc = { enabled = true, inline = false, float = false, max_width = 80, max_height = 20 },
	},
	indent = {
		enabled = true,
		indent = { enabled = false },
		animate = { duration = { step = 10, duration = 100 } },
		scope = { enabled = true, char = "┊", underline = false, only_current = true, priority = 1000 },
	},
	input = {
		enabled = true,
	},
	statuscolumn = {
		enabled = true,
		folds = {
			open = true, -- show open fold icons
			git_hl = true, -- use Git Signs hl for fold icons
		},
	},
	terminal = {
		win = {
			keys = {
				nav_h = { "<C-A-F8>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
				nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
				nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
				nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
			},
		},
	},
}
if Utils.is_win() then
	local scripts_path = vim.env.HOME .. "\\Documents\\Nushell\\Scripts\\edit_nvim_remote.nu"
	local edit = "nu " .. scripts_path .. " {{filename}} "
	local editAtLine = "nu " .. scripts_path .. "{{filename}} {{line}} "
	local openDirInEditor = "nu " .. scripts_path .. " {{dir}}"
	opts.lazygit = {
		config = {
			os = {
				edit = edit,
				editAtLine = editAtLine,
				openDirInEditor = openDirInEditor,
			},
			gui = {
				-- set to an empty string "" to disable icons
				nerdFontsVersion = "3",
			},
		},
	}
end

-- Picker
require("snacks").setup(opts)
local keys = {
	{
		"<leader>n",
		function()
			Snacks.notifier.show_history()
		end,
		desc = "Notification History",
	},
	{
		"<leader>un",
		function()
			Snacks.notifier.hide()
		end,
		desc = "Dismiss All Notifications",
	},
	{
		"<leader>pa",
		function()
			Snacks.dashboard.open()
		end,
		desc = "Open Dashboard",
	},
	{
		"<leader>z",
		function()
			Snacks.zen()
		end,
		desc = "Toggle Zen Mode",
	},
	{
		"<leader>Z",
		function()
			Snacks.zen.zoom()
		end,
		desc = "Toggle Zoom",
	},
	{
		"<leader>.",
		function()
			Snacks.scratch()
		end,
		desc = "Toggle Scratch Buffer",
	},
	{
		"<leader>S",
		function()
			Snacks.scratch.select()
		end,
		desc = "Select Scratch Buffer",
	},
	{
		"<leader>bd",
		function()
			Snacks.bufdelete()
		end,
		desc = "Delete Buffer",
	},
	{
		"<leader>rn",
		function()
			Snacks.rename.rename_file()
		end,
		desc = "Rename File",
	},
	{
		"<leader>gB",
		function()
			Snacks.gitbrowse()
		end,
		desc = "Git Browse",
		mode = { "n", "v" },
	},
	{
		"<leader>gb",
		function()
			Snacks.git.blame_line()
		end,
		desc = "Git Blame Line",
	},
	{
		"<leader>gf",
		function()
			Snacks.lazygit.log_file()
		end,
		desc = "Opens lazygit with the log of the current file",
	},
	{
		"<leader>gg",
		function()
			Snacks.lazygit()
		end,
		desc = "Lazygit",
	},
	{
		"<leader>gl",
		function()
			Snacks.lazygit.log()
		end,
		desc = "Lazygit Log (cwd)",
	},
	{
		"<c-t>",
		function()
			Snacks.terminal()
		end,
		desc = "Toggle Terminal",
	},

	{
		"<c-/>",
		function()
			Snacks.terminal()
		end,
		desc = "Toggle Terminal",
	},
	{
		"<c-_>",
		function()
			Snacks.terminal()
		end,
		desc = "which_key_ignore",
	},
	{
		"]]",
		function()
			Snacks.words.jump(vim.v.count1)
		end,
		desc = "Next Reference",
	},
	{
		"[[",
		function()
			Snacks.words.jump(-vim.v.count1)
		end,
		desc = "Prev Reference",
	},
	{
		"<leader>N",
		desc = "Neovim News",
		function()
			Snacks.win({
				file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
				width = 0.6,
				height = 0.6,
				wo = {
					spell = false,
					wrap = false,
					signcolumn = "yes",
					statuscolumn = " ",
					conceallevel = 3,
				},
			})
		end,
	},
	{
		"<leader><space>",
		function()
			Snacks.picker.smart({ confirm = { "jump", "tcd_root" } })
		end,
		desc = "Smart Find Files",
	},
	{
		"<leader>,",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers",
	},
	{
		"<leader>:",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>e",
		function()
			local opts = {}
			if vim.uv.cwd() == [[C:\Users\ziboh\.config\wezterm]] then
				opts.watch = false
			end
			Snacks.explorer(opts)
		end,
		desc = "File Explorer",
	},
	-- find
	{
		"<leader>fb",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers",
	},
	{
		"<leader>fc",
		function()
			---@diagnostic disable-next-line: assign-type-mismatch
			Snacks.picker.files({ cwd = vim.fn.stdpath("config"), confirm = { "tcd_cwd", "jump" } })
		end,
		desc = "Find Config File",
	},
	{
		"<leader>fF",
		function()
			Snacks.picker.files()
		end,
		desc = "Find Files",
	},
	{
		"<leader>fg",
		function()
			Snacks.picker.git_files()
		end,
		desc = "Find Git Files",
	},
	{
		"<leader>fp",
		function()
			Snacks.picker.projects()
		end,
		desc = "Projects",
	},
	{
		"<leader>fr",
		function()
			Snacks.picker.recent()
		end,
		desc = "Recent",
	},
	-- git
	{
		"<leader>gL",
		function()
			Snacks.picker.git_log_line()
		end,
		desc = "Git Log Line",
	},
	{
		"<leader>gs",
		function()
			Snacks.picker.git_status()
		end,
		desc = "Git Status",
	},
	{
		"<leader>gS",
		function()
			Snacks.picker.git_stash()
		end,
		desc = "Git Stash",
	},
	{
		"<leader>gD",
		function()
			Snacks.picker.git_diff()
		end,
		desc = "Git Diff (Hunks)",
	},
	-- Grep
	{
		"<leader>sb",
		function()
			Snacks.picker.lines()
		end,
		desc = "Buffer Lines",
	},
	{
		"<leader>sB",
		function()
			Snacks.picker.grep_buffers()
		end,
		desc = "Grep Open Buffers",
	},
	{
		"<leader>ff",
		function()
			Snacks.picker.grep()
		end,
		desc = "Grep",
	},
	{
		"<leader>sg",
		function()
			Snacks.picker.grep()
		end,
		desc = "Grep",
	},
	{
		"<leader>sw",
		function()
			Snacks.picker.grep_word()
		end,
		desc = "Visual selection or word",
		mode = { "n", "x" },
	},
	-- search
	{
		'<leader>s"',
		function()
			Snacks.picker.registers()
		end,
		desc = "Registers",
	},
	{
		"<leader>s/",
		function()
			Snacks.picker.search_history()
		end,
		desc = "Search History",
	},
	{
		"<leader>sa",
		function()
			Snacks.picker.autocmds()
		end,
		desc = "Autocmds",
	},
	{
		"<leader>sb",
		function()
			Snacks.picker.lines()
		end,
		desc = "Buffer Lines",
	},
	{
		"<leader>sc",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>sC",
		function()
			Snacks.picker.commands()
		end,
		desc = "Commands",
	},
	{
		"<leader>sd",
		function()
			Snacks.picker.diagnostics()
		end,
		desc = "Diagnostics",
	},
	{
		"<leader>sD",
		function()
			Snacks.picker.diagnostics_buffer()
		end,
		desc = "Buffer Diagnostics",
	},
	{
		"<leader>sh",
		function()
			Snacks.picker.help()
		end,
		desc = "Help Pages",
	},
	{
		"<leader>fh",
		function()
			Snacks.picker.help()
		end,
		desc = "Help Pages",
	},
	{
		"<leader>fh",
		function()
			Snacks.picker.help()
		end,
		desc = "Help Pages",
	},
	{
		"<leader>sH",
		function()
			Snacks.picker.highlights()
		end,
		desc = "Highlights",
	},
	{
		"<leader>si",
		function()
			Snacks.picker.icons()
		end,
		desc = "Icons",
	},
	{
		"<leader>sj",
		function()
			Snacks.picker.jumps()
		end,
		desc = "Jumps",
	},
	{
		"<leader>sk",
		function()
			Snacks.picker.keymaps()
		end,
		desc = "Keymaps",
	},
	{
		"<leader>sl",
		function()
			Snacks.picker.loclist()
		end,
		desc = "Location List",
	},
	{
		"<leader>sm",
		function()
			Snacks.picker.marks()
		end,
		desc = "Marks",
	},
	{
		"<leader>sM",
		function()
			Snacks.picker.man()
		end,
		desc = "Man Pages",
	},
	{
		"<leader>sp",
		function()
			Snacks.picker.lazy()
		end,
		desc = "Search for Plugin Spec",
	},
	{
		"<leader>sq",
		function()
			Snacks.picker.qflist()
		end,
		desc = "Quickfix List",
	},
	{
		"<leader>sR",
		function()
			Snacks.picker.resume()
		end,
		desc = "Resume",
	},
	{
		"<leader>su",
		function()
			Snacks.picker.undo()
		end,
		desc = "Undo History",
	},
	{
		"<leader>uC",
		function()
			Snacks.picker.colorschemes()
		end,
		desc = "Colorschemes",
	},
	-- LSP
	{
		"gd",
		function()
			Snacks.picker.lsp_definitions()
		end,
		desc = "Goto Definition",
	},
	{
		"gD",
		function()
			Snacks.picker.lsp_declarations()
		end,
		desc = "Goto Declaration",
	},
	{
		"gr",
		function()
			Snacks.picker.lsp_references()
		end,
		nowait = true,
		desc = "References",
	},
	{
		"gI",
		function()
			Snacks.picker.lsp_implementations()
		end,
		desc = "Goto Implementation",
	},
	{
		"gy",
		function()
			Snacks.picker.lsp_type_definitions()
		end,
		desc = "Goto T[y]pe Definition",
	},
	{
		"<leader>ss",
		function()
			Snacks.picker.lsp_symbols()
		end,
		desc = "LSP Symbols",
	},
	{
		"<leader>sS",
		function()
			Snacks.picker.lsp_workspace_symbols()
		end,
		desc = "LSP Workspace Symbols",
	},
	{
		"<leader>fn",
		function()
			Snacks.picker.notifications()
		end,
		desc = "Notifications",
	},
	{
		"<leader>fz",
		function()
			Snacks.picker.zoxide()
		end,
		desc = "Open a project from zoxide",
	},
	{
		"<leader>fu",
		function()
			Snacks.picker.undo()
		end,
		desc = "Undo",
	},
	{
		"<leader>f/",
		function()
			Snacks.picker.search_history()
		end,
		desc = "Find Search history",
	},
	{
		"<leader>fs",
		function()
			Snacks.picker.scratch()
		end,
		desc = "Find Scratch",
	},
}

Utils.setup_keymaps(keys)
