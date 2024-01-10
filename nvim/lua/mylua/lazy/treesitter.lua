return {
    -- 'nvim-treesitter/nvim-treesitter-context',

    'nvim-treesitter/nvim-treesitter',
    build = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                "vim",
                "vimdoc",
                "javascript",
                "typescript",
                "go",
                "c",
                "lua",
                "rust",
                "bash",
            },
            sync_install = false,
            auto_install = true,
            ignore_install = { "" },
            highlight = {
                enable = true,
            },
            autopairs = {
                enable = true,
            },
            indent = {
                enable = true,
            },
            playground = {
                enable = true,
            },
        })
    end
}
