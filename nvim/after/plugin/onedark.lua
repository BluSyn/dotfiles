require('onedark').setup {
    style = 'warmer',
    colors = {
        fg = '#c5c8c6',
        black = '#1d1f21',
        grey = '#969896',
        red = '#cc6666',
        cyan = '#8abeb7',
        blue = '#81a2be',
        purple = '#b294bb',
        orange = '#de935f',
        yellow = '#f0c674',
        dark_yellow = '#f0c674',
    },
    highlights = {
        ["@property"] = {fg = '$red'},
        ["@lsp.type.variable"] = {fg = '$red'},
        ["@lsp.type.property"] = {fg = '$fg'},
    },
}
vim.cmd([[colorscheme onedark]])
