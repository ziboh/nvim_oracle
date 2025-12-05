vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("FiletypeSpecificTabs", { clear = true }),
	pattern = { "text" },
	callback = function()
		vim.bo.expandtab = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("AutoSetFiletype", {}),
	pattern = "json",
	callback = function()
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

vim.api.nvim_create_autocmd("CmdLineEnter", {
	group = group,
	pattern = "*",
	callback = function()
		vim.opt.titlestring = "command"
	end,
})

vim.api.nvim_create_autocmd("CmdLineLeave", {
	group = group,
	pattern = "*",
	callback = function()
		vim.opt.titlestring = "neovim"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "snacks_picker_list",
	callback = function(args)
		vim.opt.titlestring = "neovim-explorer"
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = args.buf,
			group = group,
			callback = function()
				vim.opt.titlestring = "neovim"
			end,
			once = true,
		})
	end,
})
