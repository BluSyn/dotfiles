return {
    'neovim/nvim-lspconfig',

    dependencies = {
        -- LSP Installer
        'mason-org/mason.nvim',
        'mason-org/mason-lspconfig.nvim',

        -- Autocompletion
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-emoji',
        'hrsh7th/cmp-calc',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',

        -- Snippets
        'hrsh7th/cmp-vsnip',
        'hrsh7th/vim-vsnip',
        'rafamadriz/friendly-snippets',

        -- UI
        'j-hui/fidget.nvim',
    },

    config = function()
        -- LSP Config (Updated for Neovim 0.11/0.12+ Native API)
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' },
                    },
                }
            }
        })

        vim.lsp.config('ts_ls', {
            capabilities = lsp_capabilities,
            single_file_support = true,
            root_dir = function(fname)
                return vim.fs.root(fname, { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' })
                    or vim.fs.dirname(fname)
            end,
        })
        vim.lsp.config('eslint', { capabilities = lsp_capabilities })
        vim.lsp.config('rust_analyzer', { capabilities = lsp_capabilities })

        -- Keybindings
        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP Keybindings',
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then return end

                local buf = ev.buf
                local tele = require('telescope.builtin')
                local opts = { noremap = true, silent = true, buffer = buf }

                -- Only set Telescope mappings if the server supports the feature
                if client.server_capabilities.definitionProvider then
                    vim.keymap.set('n', 'gd', tele.lsp_definitions,
                        vim.tbl_extend('force', opts, { desc = 'LSP: [G]oto [D]efinition' }))
                end
                if client.server_capabilities.implementationProvider then
                    vim.keymap.set('n', 'gi', tele.lsp_implementations,
                        vim.tbl_extend('force', opts, { desc = 'LSP: [G]oto [I]mplementation' }))
                end
                if client.server_capabilities.typeDefinitionProvider then
                    vim.keymap.set('n', 'gt', tele.lsp_type_definitions,
                        vim.tbl_extend('force', opts, { desc = 'LSP: [G]oto [T]ype Definition' }))
                end
                if client.server_capabilities.referencesProvider then
                    vim.keymap.set('n', 'gr', tele.lsp_references,
                        vim.tbl_extend('force', opts, { desc = 'LSP: [G]oto [R]eferences' }))
                end

                -- These are safe on every server
                vim.keymap.set('n', ';', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'LSP: Hover' }))
                vim.keymap.set('n', '<leader>;', vim.lsp.buf.signature_help,
                    vim.tbl_extend('force', opts, { desc = 'LSP: Signature Help' }))
                vim.keymap.set('n', 'gar', vim.lsp.buf.rename,
                    vim.tbl_extend('force', opts, { desc = 'LSP: [G]lobal [A]ction [R]ename' }))

                -- Diagnostics (always available)
                vim.keymap.set('n', ']d', function()
                    vim.diagnostic.jump({ count = 1, float = true })
                end, vim.tbl_extend('force', opts, { desc = 'Next [D]iagnostic' }))
                vim.keymap.set('n', '[d', function()
                    vim.diagnostic.jump({ count = -1, float = true })
                end, vim.tbl_extend('force', opts, { desc = 'Previous [D]iagnostic' }))
                vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist,
                    vim.tbl_extend('force', opts, { desc = 'LSP: [D]iagnostic [Q]uickfix list' }))
            end
        })

        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = {
                'ts_ls',
                'lua_ls',
                'eslint',
                'rust_analyzer',
            },
            automatic_enable = true,
        })

        -- Autocompletion
        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            sources = {
                { name = 'vsnip' },
                { name = 'nvim_lsp' },
                { name = 'calc' },
                { name = 'buffer' },
                { name = 'path' },
                { name = 'emoji' },
                { name = 'nvim_lua' },
            },
            snippet = {
                expand = function(args)
                    -- Neovim 0.11+ has native snippets, but vsnip still works here
                    vim.fn['vsnip#anonymous'](args.body)

                    -- NOTE: If you decide to drop vsnip dependencies in the future,
                    -- you can swap to native expansion:
                    -- vim.snippet.expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
            }),
        })

        -- `/` cmdline setup.
        cmp.setup.cmdline('/', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        -- `:` cmdline setup.
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

        -- UI
        require('fidget').setup({})
    end
}
