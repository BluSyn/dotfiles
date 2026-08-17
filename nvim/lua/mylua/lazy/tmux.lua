return {
    'aserowy/tmux.nvim',
    config = function()
        -- herdr_nav owns C-h/j/k/l so herdr panes and nvim splits share them.
        -- Keep tmux.nvim for resize/swap and as a fallback when $TMUX is set.
        require('tmux').setup({
            navigation = {
                enable_default_keybindings = false,
            },
        })
        require('mylua.herdr_nav').setup()
    end,
}
