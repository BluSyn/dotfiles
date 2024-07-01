-- Fun stuff

return {
    'folke/zen-mode.nvim',
    'nvim-treesitter/playground',
    {
        'eandrju/cellular-automaton.nvim',
        config = function()
            vim.keymap.set('n', '<leader>mr', '<cmd>CellularAutomaton make_it_rain<CR>', {
                silent = true,
                desc = 'Make it rain',
            });
        end
    },
}
