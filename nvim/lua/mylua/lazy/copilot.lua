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

            local function set_keymap(mode, lhs, rhs, desc)
                local opts = { noremap = true, silent = true, desc = desc }
                vim.keymap.set(mode, lhs, rhs, opts)
            end

            set_keymap('n', '<leader>c', ':CopilotChatToggle<CR>', 'Copilot: Chat')
            set_keymap('n', '<leader>af', ':CopilotChatFix<CR>', 'Copilot: Fix')
            set_keymap('n', '<leader>ar', ':CopilotChatReview<CR>', 'Copilot: Review')
            set_keymap('n', '<leader>ao', ':CopilotChatOptimize<CR>', 'Copilot: Optimize')
            set_keymap('n', '<leader>aq', function()
                local input = vim.fn.input('Quick Chat: ')
                if input ~= '' then
                    require('CopilotChat').ask(input, {
                        selection = require('CopilotChat.select').buffer
                    })
                end
            end, 'CopilotChat - Quick chat')
        end
    },
}
