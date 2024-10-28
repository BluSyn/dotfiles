return {
    'mbbill/undotree',
    config = function()
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, {
            noremap = true,
            silent = true,
            desc = 'Toggle [u]ndotree'
        })
    end
}
