require'nvim-treesitter.configs'.setup {
    ensure_installed = { "vimdoc", "javascript", "typescript", "go", "c", "lua", "rust", "bash", "vim" },
    sync_install = false,
    auto_install = true,
    ignore_install = { "" },
    matchup = {
        enable = true,
        disable_virtual_text = true,
        disable = { "html" },
        -- include_match_words = false
    },
    highlight = {
        -- use_languagetree = true,
        enable = true,
        -- disable = { "css", "html" },
        -- disable = { "css", "markdown" },
        disable = { "markdown" },
        -- additional_vim_regex_highlighting = true,
    },
    autopairs = {
        enable = true,
    },
    indent = {
        enable = true,
    },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    autotag = {
        enable = true,
        disable = { "xml", "markdown" },
    },
    rainbow = {
        enable = false,
        extended_mode = false,
    },
    playground = {
        enable = true,
    },
}
