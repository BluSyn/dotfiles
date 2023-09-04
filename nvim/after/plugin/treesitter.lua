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
    indent = { enable = true, disable = { "python", "css", "rust" } },
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
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["at"] = "@class.outer",
                ["it"] = "@class.inner",
                ["ac"] = "@call.outer",
                ["ic"] = "@call.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["ai"] = "@conditional.outer",
                ["ii"] = "@conditional.inner",
                ["a/"] = "@comment.outer",
                ["i/"] = "@comment.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
                ["as"] = "@statement.outer",
                ["is"] = "@scopename.inner",
                ["aA"] = "@attribute.outer",
                ["iA"] = "@attribute.inner",
                ["aF"] = "@frame.outer",
                ["iF"] = "@frame.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>."] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>,"] = "@parameter.inner",
            },
        },
    },
}
