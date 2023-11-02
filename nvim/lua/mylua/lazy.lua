return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies  = { {'nvim-lua/plenary.nvim'} },
    },

    {
        'folke/trouble.nvim',
        config = {
            icons = false,
        }
    },

    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end
    },

    'nvim-treesitter/playground',
    'theprimeagen/harpoon',
    'mbbill/undotree',
    'tpope/vim-fugitive',
    -- 'nvim-treesitter/nvim-treesitter-context',
    'terrortylor/nvim-comment',

    'folke/which-key.nvim',

    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'hrsh7th/cmp-cmdline'},
            {'hrsh7th/cmp-emoji'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},
            {'saadparwaiz1/cmp_luasnip'},
            	-- nvim-cmp

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    },

    'folke/zen-mode.nvim',
    'github/copilot.vim',
    'eandrju/cellular-automaton.nvim',

    -- colorschemes
    'Yazeed1s/minimal.nvim',
    'navarasu/onedark.nvim',
    {
        'sainnhe/gruvbox-material',
        enabled = true,
        config = function()
            vim.cmd([[colorscheme gruvbox-material]])
        end,
    },
}
