vim.pack.add({
    { src = "https://github.com/catppuccin/nvim" },
})

require("catppuccin").setup({
    transparent_background = true,
    term_colors = true,
    highlight_overrides = {
        mocha = function(mocha)
            return {
                CursorLineNr = { fg = mocha.yellow },
                NormalFloat = { bg = "NONE" },
                FloatBorder = { bg = "NONE" },
                FloatTitle = { bg = "NONE" },
                RenderMarkdownCode = { bg = mocha.crust },
                SnacksPickerBorder = { bg = "NONE" },
                Pmenu = { bg = mocha.base },
            }
        end,
    },
})
vim.cmd("colorscheme catppuccin")
vim.cmd.hi("statusline guibg=NONE")
vim.cmd.hi("Comment gui=none")
