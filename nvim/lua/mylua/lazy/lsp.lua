return {
    'neovim/nvim-lspconfig',

    dependencies = {
        -- LSP Installer
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',

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
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {
                    noremap = true,
                    silent = true,
                    desc = 'Next [D]iagnostic'
                })
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {
                    noremap = true,
                    silent = true,
                    desc = 'Next [D]iagnostic'
                })
            end
        })

        -- LSP Config
        local lsp_config = require('lspconfig')
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                'ts_ls',
                'rust_analyzer',
                'lua_ls',
            },
            automatic_installation = true,
            handlers = {
                function(server)
                    lsp_config[server].setup({
                        capabilities = lsp_capabilities,
                    })
                end,
                ["lua_ls"] = function()
                    lsp_config.lua_ls.setup({
                        capabilities = lsp_capabilities,
                        settings = {
                            Lua = {
                                runtime = {
                                    version = 'LuaJIT'
                                },
                                diagnostics = {
                                    globals = { 'vim' },
                                },
                                workspace = {
                                    library = {
                                        vim.env.VIMRUNTIME,
                                    }
                                }
                            }
                        }
                    })
                end,
                ["tailwindcss"] = function()
                    lsp_config.tailwindcss.setup({
                        capabilities = lsp_capabilities,
                        root_dir = function(fname)
                            local root_pattern = require("lspconfig").util.root_pattern(
                                "tailwind.config.cjs",
                                "tailwind.config.js",
                                "postcss.config.js"
                            )
                            return root_pattern(fname)
                        end,
                    })
                end,
            }
        })

        -- Format
        vim.api.nvim_create_autocmd('BufWritePre', {
            desc = 'LSP Format',
            pattern = '*',
            callback = function()
                vim.lsp.buf.format()
            end
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
                    vim.fn["vsnip#anonymous"](args.body)
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
