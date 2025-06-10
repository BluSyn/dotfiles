return {
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = '<Right>',
                    accept_word = false,
                    accept_line = false,
                },
            },
            telemetry = {
                telemetryLevel = 'off',
            },
            -- auth_provider_url = 'http://127.0.0.1:1234/',
            -- copilot_model = '',
        },
    },
    {
        'GeorgesAlkhouri/nvim-aider',
        cmd = 'Aider',
        -- Example key mappings for common actions:
        keys = {
            { '<leader>a/', '<cmd>Aider toggle<cr>',       desc = 'Toggle Aider' },
            { '<leader>as', '<cmd>Aider send<cr>',         desc = 'Send to Aider', mode = { 'n', 'v' } },
            { '<leader>ac', '<cmd>Aider command<cr>',      desc = 'Aider Commands' },
            { '<leader>ab', '<cmd>Aider buffer<cr>',       desc = 'Send Buffer' },
            { '<leader>a+', '<cmd>Aider add<cr>',          desc = 'Add File' },
            { '<leader>a-', '<cmd>Aider drop<cr>',         desc = 'Drop File' },
            { '<leader>ar', '<cmd>Aider add readonly<cr>', desc = 'Add Read-Only' },
            { '<leader>aR', '<cmd>Aider reset<cr>',        desc = 'Reset Session' },
        },
        dependencies = {
            'folke/snacks.nvim',
        },
        config = function()
            require('nvim_aider').setup({
                auto_reload = true,
            })
        end,
    },
    -- {
    --     'TabbyML/vim-tabby',
    --     lazy = false,
    --     dependencies = {
    --         'neovim/nvim-lspconfig',
    --     },
    --     init = function()
    --         vim.g.tabby_inline_completion_keybinding_accept = '<Right>'
    --         vim.g.tabby_agent_start_command = { 'npx', 'tabby-agent', '--stdio' }
    --         vim.g.tabby_inline_completion_trigger = 'auto'
    --     end,
    -- },
    -- {
    --     'huggingface/llm.nvim',
    --     config = function()
    --         require('llm').setup({
    --             backend = 'openai',
    --             -- model = 'deepseek-coder-v2-lite-instruct-mlx',
    --             -- url = 'http://localhost:1234/v1',
    --             model = 'google/gemini-2.0-flash-001',
    --             url = 'https://openrouter.ai/api/v1/',
    --             api_token = '', -- OPENROUTER_API_KEY
    --             request_body = {
    --                 temperature = 0.2,
    --                 top_p = 0.95,
    --             },
    --             accept_keymap = '<Right>',
    --             dismiss_keymap = '<Left>',
    --         })
    --     end,
    -- },
    -- {
    --     'milanglacier/minuet-ai.nvim',
    --     config = function()
    --         require('minuet').setup {
    --             provider = 'openai_compatible',
    --             provider_options = {
    --                 openai_compatible = {
    --                     model = 'qwen/qwen2.5-32b-instruct',
    --                     system = 'see [Prompt] section for the default value',
    --                     few_shots = 'see [Prompt] section for the default value',
    --                     chat_input = 'See [Prompt Section for default value]',
    --                     stream = true,
    --                     end_point = 'https://openrouter.ai/api/v1/chat/completions',
    --                     api_key = 'OPENROUTER_API_KEY',
    --                     name = 'Openrouter',
    --                     optional = {
    --                         stop = nil,
    --                         max_tokens = nil,
    --                     },
    --                 }
    --             }
    --         }
    --     end,
    -- },
    -- {
    --     'CopilotC-Nvim/CopilotChat.nvim',
    --     dependencies = {
    --         'zbirenbaum/copilot.lua',
    --         'nvim-lua/plenary.nvim',
    --     },
    --     build = 'make tiktoken',
    --     config = function()
    --         require('CopilotChat').setup({
    --             mappings = {
    --                 reset = {
    --                     normal = '<C-d>',
    --                     insert = '<C-d>',
    --                 },
    --             },
    --         })
    --
    --         local function set_keymap(mode, lhs, rhs, desc)
    --             local opts = { noremap = true, silent = true, desc = desc }
    --             vim.keymap.set(mode, lhs, rhs, opts)
    --         end
    --
    --         set_keymap('n', '<leader>c', ':CopilotChatToggle<CR>', 'Copilot: Chat')
    --         set_keymap('n', '<leader>af', ':CopilotChatFix<CR>', 'Copilot: Fix')
    --         set_keymap('n', '<leader>ar', ':CopilotChatReview<CR>', 'Copilot: Review')
    --         set_keymap('n', '<leader>ao', ':CopilotChatOptimize<CR>', 'Copilot: Optimize')
    --         set_keymap('n', '<leader>aq', function()
    --             local input = vim.fn.input('Quick Chat: ')
    --             if input ~= '' then
    --                 require('CopilotChat').ask(input, {
    --                     selection = require('CopilotChat.select').buffer
    --                 })
    --             end
    --         end, 'CopilotChat - Quick chat')
    --     end
    -- },
}
