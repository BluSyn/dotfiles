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

    config = function ()
        -- Keybindings
        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP Keybindings',
            callback = function()
                local bufnr = vim.api.nvim_get_current_buf()
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = 'LSP: ' .. desc
                    end

                    vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
                end

                nmap(';', vim.lsp.buf.hover, 'Hover')
                nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
                nmap('gar', vim.lsp.buf.rename, '[G]lobal [A]ction [R]ename')
                nmap('[d', vim.diagnostic.goto_next, 'Next [D]iagnostic')
                nmap(']d', vim.diagnostic.goto_prev, 'Prev [D]iagnostic')
            end
        })

        -- LSP Config
        local lsp_config = require('lspconfig')
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                'tsserver',
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
            }
        })

        -- Custom LSP configs
        lsp_config.rust_analyzer.setup({
            capabilities = lsp_capabilities,
            settings = {
                rust = {
                    hint = { enable = true },
                }
            }
        })

        lsp_config.lua_ls.setup({
            capabilities = lsp_capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    diagnostics = {
                        globals = {'vim'},
                    },
                    workspace = {
                        library = {
                            vim.env.VIMRUNTIME,
                        }
                    }
                }
            }
        })

        -- Format
        vim.api.nvim_create_autocmd('BufWritePost', {
            desc = 'LSP Format',
            pattern = '*',
            callback = function()
                -- TODO: Write could create a loop?
                -- Should lock the buffer while formatting?
                vim.lsp.buf.format()
                vim.cmd(':w')
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
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<C-Space>'] = cmp.mapping.complete(),
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
            sources = cmp.config.sources({{ name = 'path' }}, {{ name = 'cmdline' }})
        })

        -- UI
        require('fidget').setup({})
    end
}
