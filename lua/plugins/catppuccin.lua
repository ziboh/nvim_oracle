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
vim.api.nvim_set_hl(0, "statusline", { bg = "NONE" })
vim.api.nvim_set_hl(0, "Comment", { bg = "NONE" })
vim.api.nvim_set_hl(0, "YankyYanked", { fg = "#161b22", bg = "#ff8f62" })
