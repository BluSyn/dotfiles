local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
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
    nmap('gh', function() if vim.lsp.inlay_hint then vim.lsp.inlay_hint(0, nil) end end, '[G]lobal [H]ints toggle')
    nmap('[d', vim.diagnostic.goto_next, 'Next [D]iagnostic')
    nmap(']d', vim.diagnostic.goto_prev, 'Prev [D]iagnostic')

    -- lsp.buffer_autoformat()
end)

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'tsserver', 'rust_analyzer' },
    handlers = {
        lsp.default_setup,
        rust_analyzer = function()
            require('lspconfig').rust_analyzer.setup({
                settings = {
                    rust = {
                        hint = { enable = true },
                    }
                }
            })
        end
    }
})

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
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    formatting = lsp.cmp_format(),
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
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
