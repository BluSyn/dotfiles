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

    'nvim-lualine/lualine.nvim',
    'nvim-tree/nvim-web-devicons',

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
            {'hrsh7th/cmp-calc'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            { 'hrsh7th/cmp-vsnip' },
            { 'hrsh7th/vim-vsnip' },
            {'rafamadriz/friendly-snippets'},
        }
    },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
    },

    {
        "aserowy/tmux.nvim",
        config = function()
            require("tmux").setup()
        end,
    },

    -- Fun stuff
    'folke/zen-mode.nvim',
    'eandrju/cellular-automaton.nvim',

    -- colorschemes
    'navarasu/onedark.nvim',
}
