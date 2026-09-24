return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    -- Runs only when the plugin is installed or updated, not on every launch.
    build = ':TSUpdate',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
        require('nvim-treesitter').setup({
            -- Puts compiled parsers and queries ahead of leftover builds
            -- that the old plugin layout left inside the plugin directory.
            install_dir = vim.fn.stdpath('data') .. '/site',
        })

        -- FileType (including Neovim's own ftplugins) calls this with no
        -- pcall. language.add() returns false, it does not throw, when no
        -- parser is installed. Starting anyway prints "Parser could not be
        -- created" on the command line, and the next keystroke clears it.
        local start = vim.treesitter.start
        function vim.treesitter.start(buf, lang)
            buf = buf or vim.api.nvim_get_current_buf()
            if not lang or lang == '' then
                local ft = vim.bo[buf].filetype
                lang = vim.treesitter.language.get_lang(ft) or ft
            end
            if not lang or lang == '' then
                return
            end
            local ok_add, added = pcall(vim.treesitter.language.add, lang)
            if not ok_add or not added then
                return
            end
            if not pcall(vim.treesitter.query.get, lang, 'highlights') then
                return
            end
            pcall(start, buf, lang)
        end

        vim.api.nvim_create_autocmd('FileType', {
            callback = function(args)
                vim.treesitter.start(args.buf)
            end,
        })

        require('treesitter-context').setup({
            enable = true,
        })
    end,
}
