return {
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept = '<C-l>',
                        accept_word = false,
                        accept_line = false,
                    },
                }
            })
        end
    },
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        dependencies = {
            'zbirenbaum/copilot.lua',
            'nvim-lua/plenary.nvim',
        },
        build = 'make tiktoken',
        config = function()
            require('CopilotChat').setup({
                mappings = {
                    reset = {
                        normal = '<C-d>',
                        insert = '<C-d>',
                    },
                },
            })

            local keymap = vim.keymap.set
            local opts = { noremap = true, silent = true }

            keymap('n', '<leader>c', ':CopilotChatToggle<CR>', vim.tbl_extend('force', opts, { desc = 'Copilot: Chat' }))
            keymap('n', '<leader>af', ':CopilotChatFix<CR>', vim.tbl_extend('force', opts, { desc = 'Copilot: Fix' }))
            keymap('n', '<leader>ar', ':CopilotChatReview<CR>',
                vim.tbl_extend('force', opts, { desc = 'Copilot: Review' }))
            keymap('n', '<leader>ao', ':CopilotChatOptimize<CR>',
                vim.tbl_extend('force', opts, { desc = 'Copilot: Optimize' }))
        end
    },
}
