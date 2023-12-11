require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "vimdoc", "javascript", "typescript", "go", "c", "lua", "rust", "bash", "vim" },
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
}
