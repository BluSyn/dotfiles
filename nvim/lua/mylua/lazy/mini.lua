return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        require('mini.pairs').setup()
        require('mini.surround').setup()
        require('mini.splitjoin').setup({
            mappings = {
                toggle = '<leader>s',
            },
        })
        require('mini.comment').setup({
            mappings = {
                comment_line = '\\',
                comment_visual = '\\',
            },
        })
    end,
}
