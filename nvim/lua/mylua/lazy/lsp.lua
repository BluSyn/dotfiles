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
        -- Keybindings
        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP Keybindings',
            callback = function()
                local tele = require('telescope.builtin')
                vim.keymap.set('n', ';', vim.lsp.buf.hover, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: Hover'
                })
                vim.keymap.set('n', '<leader>;', vim.lsp.buf.signature_help, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: Signature Help'
                })
                vim.keymap.set('n', 'gi', tele.lsp_implementations, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: [G]oto [I]mplentation'
                })
                vim.keymap.set('n', 'gd', tele.lsp_definitions, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: [G]oto [D]efinition'
                })
                vim.keymap.set('n', 'gt', tele.lsp_type_definitions, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: [G]oto [T]ype Definition'
                })
                vim.keymap.set('n', 'gr', tele.lsp_references, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: [G]oto [R]eferences'
                })
                vim.keymap.set('n', 'gar', vim.lsp.buf.rename, {
                    noremap = true,
                    silent = true,
                    desc = 'LSP: [G]lobal [A]ction [R]ename'
                })
                vim.keymap.set('n', ']d', function()
                    -- goto_next deprecated in favor of jump
                    vim.diagnostic.jump({ count = 1, float = true })
                end, {
                    noremap = true,
                    silent = true,
                    desc = 'Next [D]iagnostic'
                })
                vim.keymap.set('n', '[d', function()
                    -- goto_prev deprecated in favor of jump
                    vim.diagnostic.jump({ count = -1, float = true })
                end, {
                    noremap = true,
                    silent = true,
                    desc = 'Previous [D]iagnostic'
                })
            end
        })

        -- LSP Config
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = {
                'ts_ls',
                'lua_ls',
                'eslint',
                'rust_analyzer',
            },
            automatic_installation = true,
        })

        vim.lsp.config('lua_ls', {
            capabilities = lsp_capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' },
                    },
                }
            }
        })

        -- Autocompletion
        local cmp = require('cmp')
        local cmp_select = {
            behavior = cmp.SelectBehavior.Select
        }

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
                    vim.fn['vsnip#anonymous'](args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                -- ['<C-Space>'] = cmp.mapping.complete(),
            }),
        })

        -- `/` cmdline setup.
        cmp.setup.cmdline('/', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

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
