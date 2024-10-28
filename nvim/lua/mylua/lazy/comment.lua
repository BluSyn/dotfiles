return {
    'terrortylor/nvim-comment',
    config = function()
        require('nvim_comment').setup()
        vim.keymap.set('n', '\\', ':CommentToggle<CR>', {
            noremap = true,
            silent = true,
            desc = 'Comment Line'
        })
        vim.keymap.set('v', '\\', ":'<,'>CommentToggle<CR>", {
            noremap = true,
            silent = true,
            desc = 'Comment Selection'
        })
    end
}
