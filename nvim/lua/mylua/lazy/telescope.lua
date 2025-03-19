return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        require('telescope').setup({
            defaults = {
                mappings = {
                    i = {
                        ['<C-j>'] = 'move_selection_next',
                        ['<C-k>'] = 'move_selection_previous',
                        ['<c-u>'] = 'results_scrolling_up',
                        ['<c-d>'] = 'results_scrolling_down',
                        ['<C-n>'] = 'cycle_history_next',
                        ['<C-p>'] = 'cycle_history_prev',
                        ['<C-h>'] = 'which_key',
                    },
                },
            },
        })

        local builtin = require('telescope.builtin')

        -- Search through main project files, including unstaged files
        vim.keymap.set('n', '<leader>\\', function()
            builtin.find_files({
                find_command = { 'git', 'ls-files', '--cached', '--others', '--exclude-standard' },
            })
        end, {
            noremap = true,
            silent = true,
            desc = 'Search project files',
        })

        -- Search through *all* files
        -- This will include hidden files and files in the .gitignore
        -- Such as node_modules, .git, etc.
        vim.keymap.set('n', '<leader>/', function()
            builtin.find_files({
                hidden = true,
                no_ignore = true,
            })
        end, {
            noremap = true,
            silent = true,
            desc = 'Search [a]ll files',
        })

        vim.keymap.set('n', '<leader>b', builtin.buffers, {
            noremap = true,
            silent = true,
            desc = 'Search [b]uffers',
        })
        vim.keymap.set('n', '<leader>f', builtin.live_grep, {
            noremap = true,
            silent = true,
            desc = '[F]ind in files',
        })
        vim.keymap.set('n', '<leader>h', builtin.help_tags, {
            noremap = true,
            silent = true,
            desc = 'Show [h]elp tags',
        })
        vim.keymap.set('n', '<leader>k', builtin.keymaps, {
            noremap = true,
            silent = true,
            desc = 'Show [k]eymap',
        })

        -- Mapping to reopen the last closed picker
        vim.keymap.set('n', '<leader>r', builtin.resume, {
            noremap = true,
            silent = true,
            desc = '[R]eopen the last closed picker',
        })
    end
}
