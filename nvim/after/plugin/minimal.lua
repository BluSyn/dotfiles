-- vim.cmd('colorscheme minimal-base16')

-- Fix minimal-base16 with lsp color defs

local colors = require 'minimal-base16.colors'
local function highlight(group, properties)
    local bg = properties.bg == nil and '' or 'guibg=' .. properties.bg
    local fg = properties.fg == nil and '' or 'guifg=' .. properties.fg
    local style = properties.style == nil and '' or 'gui=' .. properties.style
    local cmd = table.concat({ 'highlight', group, bg, fg, style }, ' ')
    vim.api.nvim_command(cmd)
end

highlight("Exception", { fg = colors.pink })
highlight("MatchParen", { fg = colors.orange_wr, style = 'underline' })
highlight("@field", { fg = colors.white1 })
highlight("@include", { fg = colors.pink })
highlight("@property", { fg = colors.white1 })
highlight("@variable", { fg = colors.red_key_w })
highlight("@parameter", { fg = colors.red_key_w })
highlight("@constructor", { fg = colors.blue_func })
highlight("@lsp.type.field", { fg = colors.white1 })
highlight("@lsp.type.variable", { fg = colors.red_key_w })
highlight("@lsp.type.parameter", { fg = colors.red_key_w })
highlight("@lsp.type.property", { fg = colors.white1 })
highlight("@lsp.type.interface", { fg = colors.yellow })
highlight("@lsp.type.class", { fg = colors.yellow })

-- Typescript
highlight("@type.builtin.typescript", { fg = colors.white1 })
highlight("@punctuation.bracket.typescript", { fg = colors.pink })

