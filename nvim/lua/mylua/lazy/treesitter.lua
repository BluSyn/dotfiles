return {
    'nvim-treesitter/nvim-treesitter',
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
        'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
        require('nvim-treesitter').setup({})

        local ensure_installed = {
            'vim', 'vimdoc', 'javascript', 'typescript', 'go', 'c',
            'lua', 'rust', 'bash', 'python', 'markdown', 'markdown_inline',
        }

        require('nvim-treesitter').install(ensure_installed)

        vim.api.nvim_create_autocmd('FileType', {
            callback = function(args)
                -- Start Treesitter parser (handles highlight)
                pcall(vim.treesitter.start, args.buf)

                -- Treesitter-based indentation (replaces old indent = { enable = true })
                vim.bo[args.buf].indentexpr = "v:lua.vim.treesitter.indentexpr()"
            end,
        })

        -- Your treesitter-context config (unchanged)
        require('treesitter-context').setup({
            enable = true,
        })
    end
}
