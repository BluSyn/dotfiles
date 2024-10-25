local wezterm = require 'wezterm'

return {
    default_prog = { 'fish' },

    window_padding = {
        left = 0,
        right = 0,
        top = 5,
        bottom = 0,
    },
    enable_scroll_bar = false,
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,

    font = wezterm.font('DejaVuSansM Nerd Font Mono', { weight = 'Regular' }),
    font_size = 13.0,
    color_scheme = 'Afterglow',
}
