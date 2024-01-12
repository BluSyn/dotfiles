return {
    'nvim-telescope/telescope.nvim',

    tag          = '0.1.4',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>/', function()
            require('telescope.builtin').find_files({
                -- hidden = true,
                no_ignore = true
            })
        end, {})

        -- vim.keymap.set('n', '<leader>a', builtin.git_files, {})
        vim.keymap.set('n', '<leader>b', builtin.buffers, {})
        vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
    end
}
