local palette = require("catppuccin.palettes").get_palette("mocha")
local utils = require("heirline.utils")
local conditions = require("heirline.conditions")
local icons = Utils.icons
local colors = {
	diag_warn = utils.get_highlight("DiagnosticWarn").fg,
	diag_error = utils.get_highlight("DiagnosticError").fg,
	diag_hint = utils.get_highlight("DiagnosticHint").fg,
	diag_info = utils.get_highlight("DiagnosticInfo").fg,
	git_del = utils.get_highlight("diffDeleted").fg,
	git_add = utils.get_highlight("diffAdded").fg,
	git_change = utils.get_highlight("diffChanged").fg,
}
local dim_color = palette.overlay2
-- overseer
local function OverseerTasksForStatus(st)
	return {
		condition = function(self)
			return self.tasks[st]
		end,
		provider = function(self)
			return string.format("%s%d", self.symbols[st], #self.tasks[st])
		end,
		hl = function(_)
			return {
				fg = utils.get_highlight(string.format("Overseer%s", st)).fg,
			}
		end,
	}
end
local M = {}
M.Spacer = { provider = " " }
M.Fill = { provider = "%=" }
M.Ruler = {
	-- %l = current line number
	-- %L = number of lines in the buffer
	-- %c = column number
	-- %P = percentage through file of displayed window
	provider = "%4l,%-3c %P",
}
M.FileType = {
	condition = function()
		return vim.bo.filetype ~= ""
	end,
	init = function(self)
		self.filetype = vim.bo.filetype
		if self.filetype:match("(snacks_picker).*") == "snacks_picker" then
			local explore_picker = Snacks.picker.get({ source = "explorer" })
			local explore_exist = false
			if #explore_picker ~= 0 then
				explore_picker = explore_picker[1]
				explore_exist = true
			end
			---@diagnostic disable-next-line: undefined-field
			if explore_exist and explore_picker:is_focused() then
				---@diagnostic disable-next-line: undefined-field
				local dir = explore_picker:dir()
				self.icon, self.icon_hl = Snacks.util.icon(dir, "directory")
				self.filetype = dir
			elseif self.filetype == "snacks_picker_input" then
				self.icon = ""
				self.icon_hl = "MiniIconsCyan"
				self.filetype = "Input"
			elseif self.filetype == "snacks_picker_list" then
				self.icon = ""
				self.icon_hl = "MiniIconsCyan"
				self.filetype = "List"
			elseif self.filetype == "snacks_picker_preview" then
				self.icon = ""
				self.icon_hl = "MiniIconsCyan"
				self.filetype = "Preview"
			end
		elseif self.filetype == "snacks_terminal" then
			self.icon = ""
			self.icon_hl = "MiniIconsCyan"
			self.filetype = "Terminal"
		elseif self.filetype == "snacks_input" then
			self.icon = ""
			self.icon_hl = "MiniIconsCyan"
			self.filetype = "Input"
		else
			self.icon, self.icon_hl = Snacks.util.icon(self.filetype, "filetype")
		end
	end,
	{
		provider = function(self)
			return self.icon .. " "
		end,
		hl = function(self)
			return self.icon_hl
		end,
	},
	{
		provider = function(self)
			return self.filetype
		end,
	},
}
M.FileCode = {
	condition = function()
		return vim.bo.fenc ~= ""
	end,
	{
		hl = { fg = "#50a4e9", bold = true },
		provider = function()
			local enc = vim.bo.fenc
			if enc == "euc-cn" then
				enc = "gbk"
			end
			return enc ~= "" and enc:upper() .. "[" .. vim.bo.ff:sub(1, 1):upper() .. vim.bo.ff:sub(2) .. "]"
		end,
	},
}
M.Rime = {
	condition = function()
		local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
		for _, client in ipairs(clients) do
			if client.name == "rime_ls" then
				return true
			end
		end
		return false
	end,
	on_click = {
		name = "heirline_rime",
		callback = function()
			Snacks.toggle.get("rime"):toggle()
		end,
	},
	flexible = 10,
	static = {
		icon = " ",
		text = "Rime",
		enabled_hl = { fg = "#98bb6c", bold = true },
		disabled_hl = { fg = "#ed8796", bold = true },
	},
	init = function(self)
		if vim.g.rime_enabled then
			self.hl = self.enabled_hl
		else
			self.hl = self.disabled_hl
		end
	end,
	{
		provider = function(self)
			return self.icon .. self.text
		end,
	},
	{
		provider = function(self)
			return self.icon
		end,
	},
}
M.SuperMaven = {
	on_click = {
		name = "heirline_supermaven",
		callback = function()
			Snacks.toggle.get("supermaven"):toggle()
		end,
	},
	static = {
		icon = " ",
		text = "SuperMaven",
		enabled_hl = { fg = "#98bb6c", bold = true },
		disabled_hl = { fg = "#ed8796", bold = true },
	},
	init = function(self)
		if vim.g.supermaven_enabled then
			self.hl = self.enabled_hl
		else
			self.hl = self.disabled_hl
		end
	end,
	flexible = 10,
	{
		provider = function(self)
			return self.icon .. self.text
		end,
	},
	{
		provider = function(self)
			return self.icon
		end,
	},
	hl = function(self)
		return self.hl
	end,
}
M.ScrollBar = {
	static = {
		sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
	},
	provider = function(self)
		local curr_line = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_line_count(0)
		local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
		return string.rep(self.sbar[i], 2)
	end,
	hl = { fg = palette.yellow, bg = palette.base },
}

-- Spacing providers
M.RightPadding = function(child, num_space)
	local result = {
		condition = child.condition,
		child,
	}
	if num_space ~= nil then
		for _ = 1, num_space do
			table.insert(result, M.Spacer)
		end
	end
	return result
end
M.Mode = {
	init = function(self)
		self.mode = vim.fn.mode(1)
	end,
	static = {
		mode_names = { -- change the strings if you like it vvvvverbose!
			n = "NORMAL",
			no = "?",
			nov = "?",
			noV = "?",
			["no\22"] = "?",
			niI = "i",
			niR = "r",
			niV = "Nv",
			nt = "N-TERM",
			v = "VISUAL",
			vs = "Vs",
			V = "V-LINE",
			Vs = "Vs",
			["\22"] = "VBLOCK",
			["\22s"] = "\\",
			s = "SELECT",
			S = "S-LINE",
			["\19"] = "^S",
			i = "INSERT",
			ic = "Ic",
			ix = "Ix",
			R = "RPLACE",
			Rc = "Rc",
			Rx = "Rx",
			Rv = "V-RPLC",
			Rvc = "Rv",
			Rvx = "Rv",
			c = "CMD",
			cv = "Ex",
			r = "...",
			rm = "M",
			["r?"] = "?",
			["!"] = "!",
			t = "TERM",
		},
		mode_colors = {
			n = palette.sky,
			nt = dim_color,

			i = palette.blue,
			v = palette.mauve,
			V = palette.mauve,
			["\22"] = palette.mauve,
			c = palette.red,
			s = palette.pink,
			S = palette.pink,
			["\19"] = palette.pink,
			R = palette.peach,
			r = palette.peach,
			["!"] = palette.red,
			t = palette.blue,
		},
	},
	provider = function(self)
		return " " .. "%1(" .. self.mode_names[self.mode] .. "%)" .. " ▍"
	end,
	hl = function(self)
		local mode = self.mode:sub(1, 1) -- get only the first mode character
		return { fg = palette.base, bg = self.mode_colors[mode], bold = true }
	end,
	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			---@diagnostic disable-next-line: param-type-mismatch
			pcall(vim.cmd, "redrawstatus")
		end),
	},
}

M.MacroRecording = {
	condition = conditions.is_active,
	init = function(self)
		self.reg_recording = vim.fn.reg_recording()
		self.status_dict = vim.b.gitsigns_status_dict or { added = 0, removed = 0, changed = 0 }
		self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
	end,
	{
		condition = function(self)
			return self.reg_recording ~= ""
		end,
		{
			provider = "󰻃 ",
			hl = { fg = palette.maroon },
		},
		{
			provider = function(self)
				return self.reg_recording
			end,
			hl = { fg = palette.maroon, italic = false, bold = true },
		},
		hl = { fg = palette.text, bg = palette.base },
	},
	update = { "RecordingEnter", "RecordingLeave" },
} -- MacroRecording

M.LspServer = {
	flexible = 1,
	on_click = {
		name = "heirline_lsp_info",
		callback = function()
			Snacks.picker.lsp_config()
		end,
	},
	{
		provider = function(self)
			local names = self.lsp_filtered_table
			if #names == 0 then
				return ""
			else
				return " [" .. table.concat(names, ", ") .. "]"
			end
		end,
	},
	{
		provider = function(self)
			local names = self.lsp_filtered_table
			if #names == 0 then
				return ""
			else
				return " [LSP]"
			end
		end,
	},
}
M.Lsp = {
	condition = conditions.lsp_attached,
	init = function(self)
		local names = {}
		self.ignore_lsp = { "rime_ls" }
		local lsp_filtered_table = {}

		for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
			table.insert(names, server.name)
			if
				not Utils.value_in_list(server.name, self.ignore_lsp)
				and not Utils.value_in_list(server.name, lsp_filtered_table)
			then
				table.insert(lsp_filtered_table, server.name)
			end
		end
		if Utils.has("lint") then
			for _, lint in pairs(require("lint")._resolve_linter_by_ft(vim.bo.filetype)) do
				table.insert(names, lint)
				if
					not Utils.value_in_list(lint, self.ignore_lsp) and not Utils.value_in_list(lint, lsp_filtered_table)
				then
					table.insert(lsp_filtered_table, lint)
				end
			end
		end

		for _, formatter in pairs(require("conform").list_formatters()) do
			table.insert(names, formatter.name)
			if
				not Utils.value_in_list(formatter.name, self.ignore_lsp)
				and not Utils.value_in_list(formatter.name, lsp_filtered_table)
			then
				table.insert(lsp_filtered_table, formatter.name)
			end
		end

		self.lsp_names = names
		self.lsp_filtered_table = lsp_filtered_table
	end,
	hl = { fg = "#98bb6c", bold = true },
	{
		condition = function(self)
			return #self.lsp_filtered_table > 0
		end,
	},
	M.LspServer,
}

-- Git
M.Git = {
	condition = conditions.is_git_repo,

	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
		self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
	end,

	hl = function(self)
		return { fg = self.has_changes and palette.maroon or dim_color }
	end,

	{ -- git branch name
		provider = function(self)
			if self.has_changes then
				return "󰘬 " .. self.status_dict.head .. "*"
			else
				return "󰘬 " .. self.status_dict.head
			end
		end,
	},
	-- {
	--   condition = function(self)
	--     return self.has_changes
	--   end,
	--   provider = '(',
	-- },
	-- {
	--   provider = function(self)
	--     local count = self.status_dict.added or 0
	--     return count > 0 and ('+' .. count)
	--   end,
	--   hl = { fg = colors.git_add },
	-- },
	-- {
	--   provider = function(self)
	--     local count = self.status_dict.removed or 0
	--     return count > 0 and ('-' .. count)
	--   end,
	--   hl = { fg = colors.git_del },
	-- },
	-- {
	--   provider = function(self)
	--     local count = self.status_dict.changed or 0
	--     return count > 0 and ('~' .. count)
	--   end,
	--   hl = { fg = colors.git_change },
	-- },
	-- {
	--   condition = function(self)
	--     return self.has_changes
	--   end,
	--   provider = ')',
	-- },
	-- on_click = {
	--   name = 'heirline_git',
	--   callback = function()
	--     ---@diagnostic disable-next-line: missing-fields
	--     Snacks.lazygit { cwd = Snacks.git.get_root() }
	--   end,
	-- },
}

-- Dianostics
M.Diagnostics = {
	condition = conditions.has_diagnostics,
	static = {
		error_icon = icons.diagnostics.Error .. " ",
		warn_icon = icons.diagnostics.Warn .. " ",
		info_icon = icons.diagnostics.Info .. " ",
		hint_icon = icons.diagnostics.Hint .. " ",
	},

	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,

	update = { "DiagnosticChanged", "BufEnter" },

	{
		provider = function(self)
			-- 0 is just another output, we can decide to print it or not!
			return self.errors > 0 and (self.error_icon .. self.errors .. " ")
		end,
		hl = { fg = colors.diag_error },
	},
	{
		provider = function(self)
			return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
		end,
		hl = { fg = colors.diag_warn },
	},
	{
		provider = function(self)
			return self.info > 0 and (self.info_icon .. self.info .. " ")
		end,
		hl = { fg = colors.diag_info },
	},
	{
		provider = function(self)
			return self.hints > 0 and (self.hint_icon .. self.hints)
		end,
		hl = { fg = colors.diag_hint },
	},
	-- on_click = {
	--   name = 'heirline_diagnostic',
	--   callback = function()
	--     Snacks.picker.diagnostics_buffer()
	--   end,
	-- },
} -- Diagnostics

-- we redefine the filename component, as we probably only want the tail and not the relative path
M.FilePath = {
	provider = function(self)
		-- first, trim the pattern relative to the current directory. For other
		-- options, see :h filename-modifers
		local filename = vim.fn.fnamemodify(self.filename, ":.")
		if filename == "" then
			return vim.bo.filetype ~= "" and vim.bo.filetype or vim.bo.buftype
		end
		-- now, if the filename would occupy more than 1/4th of the available
		-- space, we trim the file path to its initials
		-- See Flexible Components section below for dynamic truncation
		-- if not conditions.width_percent_below(#filename, 0.25) then
		--   filename = vim.fn.pathshorten(filename, 4)
		-- end
		return filename
	end,
	hl = function(self)
		return {
			fg = self.is_active and palette.text or palette.subtext0,
			bold = self.is_active or self.is_visible,
			italic = self.is_active,
		}
	end,
}

M.Overseer = {
	condition = function()
		return package.loaded.overseer
	end,
	init = function(self)
		local tasks = require("overseer.task_list").list_tasks({ unique = true })
		local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")
		self.tasks = tasks_by_status
	end,
	static = {
		symbols = {
			["CANCELED"] = " 󰩹 ",
			["FAILURE"] = "  ",
			["SUCCESS"] = "  ",
			["RUNNING"] = "  ",
		},
	},
	M.RightPadding(OverseerTasksForStatus("CANCELED")),
	M.RightPadding(OverseerTasksForStatus("RUNNING")),
	M.RightPadding(OverseerTasksForStatus("SUCCESS")),
	M.RightPadding(OverseerTasksForStatus("FAILURE")),
}

vim.opt.showcmdloc = "statusline"
M.ShowCmd = {
	condition = function()
		return vim.o.cmdheight == 0
	end,
	provider = "%3.5(%S%)",
}

M.SearchOccurrence = {
	condition = function()
		return vim.v.hlsearch == 1
	end,
	hl = { fg = palette.sky },
	provider = function()
		local sinfo = vim.fn.searchcount({ maxcount = 0 })
		local search_stat = sinfo.incomplete > 0 and " [?/?]"
			or sinfo.total > 0 and (" [%s/%s]"):format(sinfo.current, sinfo.total)
			or ""
		return search_stat
	end,
}

M.SimpleIndicator = {
	condition = function()
		return vim.g.simple_indicator_on
	end,
	hl = { fg = palette.sky },
	provider = "",
}

return M
