return {
    'terrortylor/nvim-comment',
    config = function()
        require('nvim_comment').setup()
        vim.keymap.set('n', '\\', ':CommentToggle<CR>', { silent = true, desc = "Comment Line" })
        vim.keymap.set('v', '\\', ":'<,'>CommentToggle<CR>", { silent = true, desc = "Comment Selection" })
    end
}
