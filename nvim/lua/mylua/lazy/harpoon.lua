return {
    'theprimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local harpoon = require('harpoon')
        harpoon:setup()

        vim.keymap.set('n', 'gm', function() harpoon:list():add() end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: [m]ark file',
        })
        vim.keymap.set('n', 'gl', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: [l]ist files',
        })
        vim.keymap.set('n', 'gn', function() harpoon:list():next() end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: [n]ext file',
        })
        vim.keymap.set('n', 'gp', function() harpoon:list():prev() end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: [p]revious file',
        })
        vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: Select 1',
        })
        vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: Select 2',
        })
        vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end, {
            noremap = true,
            silent = true,
            desc = 'Harpoon: Select 3',
        })
    end
}
