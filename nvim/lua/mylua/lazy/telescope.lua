return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    config = function()
        require('telescope').setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                    },
                },
            },
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>\\', function()
            builtin.find_files({
                -- hidden = true,
                no_ignore = true,
            })
        end, {})

        -- vim.keymap.set('n', '<leader>a', builtin.git_files, {})
        vim.keymap.set('n', '<leader>b', builtin.buffers, {})
        vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
    end
}
