-- Normal mode --
-----------------
vim.keymap.set("n", "<C-n>", "5j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", "5k", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("n", "q", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("n", "J", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-b>", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("n", "<tab>", "w", { noremap = true, silent = true })

vim.keymap.set("n", "L", "$", { noremap = true, silent = true, desc = "Move to end of line" })
vim.keymap.set("n", "H", "^", { noremap = true, silent = true, desc = "Move to first non-blank character" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Decrease window height" })
vim.keymap.set("n", "M", "J", { noremap = true, silent = true, desc = "Join the current line with the next line" })
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "Toggle Comment linewise" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle Comment lineise" })

-----------------
-- Visual mode --
-----------
vim.keymap.set("v", "<C-n>", "5j", { noremap = true, silent = true })
vim.keymap.set("v", "<C-p>", "5k", { noremap = true, silent = true })
vim.keymap.set("v", "L", "$h", { noremap = true, silent = true, desc = "Move to end of line" })
vim.keymap.set("v", "H", "^", { noremap = true, silent = true, desc = "Move to first non-blank character" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true, desc = "Unindent line" })
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true, desc = "Unindent line" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv-gv", { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv-gv", { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set("v", "J", "<NOP>", { noremap = true, silent = true })
vim.keymap.set("v", "J", "j", { noremap = true, silent = true })
vim.keymap.set("v", "K", "k", { noremap = true, silent = true })

-----------------
-- Insert mode --
-----------------
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, silent = true, desc = "Move line down" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("o", "H", "^", { noremap = true, silent = true, desc = "Move to first non-blank character" })
vim.keymap.set("o", "L", "$", { noremap = true, silent = true, desc = "Move to end of line" })

-- quit
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa<cr>", { noremap = true, silent = true, desc = "Quit All" })
vim.keymap.set(
	{ "i", "x", "n", "s" },
	"<C-s>",
	"<cmd>w<cr><esc>",
	{ noremap = true, silent = true, desc = "Save File" }
)

-- smart-splits.nivm
if not Utils.has("smart-splits.nvim") then
	-- 使用 <C-h/j/k/l> 在窗口之间移动
	vim.keymap.set("n", "<C-A-F8>", "<C-w>h", { desc = "Move to left split", noremap = true, silent = true })
	vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below split", noremap = true, silent = true })
	vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above split", noremap = true, silent = true })
	vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split", noremap = true, silent = true })
	-- 使用 <C-方向键> 调整窗口大小
	vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<CR>", { desc = "Resize split up", noremap = true, silent = true })
	vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<CR>", { desc = "Resize split down", noremap = true, silent = true })
	vim.keymap.set(
		"n",
		"<C-Left>",
		"<cmd>vertical resize -2<CR>",
		{ desc = "Resize split left", noremap = true, silent = true }
	)
	vim.keymap.set(
		"n",
		"<C-Right>",
		"<cmd>vertical resize +2<CR>",
		{ desc = "Resize split right", noremap = true, silent = true }
	)
end

vim.keymap.set("n", "<leader>ww", "<c-w>w", { noremap = true, silent = true, desc = "other window" })
vim.keymap.set("n", "<leader>wd", "<c-w>c", { noremap = true, silent = true, desc = "delete window" })
vim.keymap.set("n", "<leader>wl", "<c-w>v", { noremap = true, silent = true, desc = "spite window right" })
vim.keymap.set("n", "<leader>wj", "<c-w>s", { noremap = true, silent = true, desc = "splite window below" })
vim.keymap.set("n", "<leader>wo", "<c-w>o", { noremap = true, silent = true, desc = "only window" })
vim.keymap.set("n", "<leader>wx", "<c-w>x", { noremap = true, silent = true, desc = "Swap current with next" })
vim.keymap.set("n", "<leader>wf", "<c-w>p", { noremap = true, silent = true, desc = "switch window" })
vim.keymap.set("n", "|", "<cmd>vsplit<cr>", { noremap = true, silent = true, desc = "Vertical Split" })
vim.keymap.set("n", "<C-|>", "<cmd>split<cr>", { noremap = true, silent = true, desc = "Horizontal Split" })

vim.keymap.set("n", "<leader>ld", function()
	vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = "Hover diagnostics" })
