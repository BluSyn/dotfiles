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
            -- doesnt actually work?
            copilot_model = 'xai-grok-code-fast-1',
        },
    },
    {
        "folke/sidekick.nvim",
        opts = {
            nes = { enabled = false },
            mux = {
                backend = "tmux",
                enabled = true,
            },
        },
        -- stylua: ignore
        keys = {
            {
                "<tab>",
                function()
                    -- if there is a next edit, jump to it, otherwise apply it if any
                    if require("sidekick").nes_jump_or_apply() then
                        return -- jumped or applied
                    end

                    -- if you are using Neovim's native inline completions
                    if vim.lsp.inline_completion.get() then
                        return
                    end

                    -- any other things (like snippets) you want to do on <tab> go here.

                    -- fall back to normal tab
                    return "<tab>"
                end,
                mode = { "i", "n" },
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<leader>aa",
                function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
                desc = "Sidekick Toggle Opencode",
            },
            {
                "<leader>as",
                function() require("sidekick.cli").select() end,
                desc = "Sidekick Select CLI",
            },
            {
                "<leader>ai",
                function() require("sidekick.cli").toggle({ name = "aider", focus = true }) end,
                desc = "Sidekick Toggle Aider",
            },
            {
                "<leader>at",
                function() require("sidekick.cli").send({ msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ msg = "{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
        },
    },
    -- {
    --     'GeorgesAlkhouri/nvim-aider',
    --     cmd = 'Aider',
    --     -- Example key mappings for common actions:
    --     keys = {
    --         { '<leader>a/', '<cmd>Aider toggle<cr>',       desc = 'Toggle Aider' },
    --         { '<leader>as', '<cmd>Aider send<cr>',         desc = 'Send to Aider', mode = { 'n', 'v' } },
    --         { '<leader>ac', '<cmd>Aider command<cr>',      desc = 'Aider Commands' },
    --         { '<leader>ab', '<cmd>Aider buffer<cr>',       desc = 'Send Buffer' },
    --         { '<leader>a+', '<cmd>Aider add<cr>',          desc = 'Add File' },
    --         { '<leader>a-', '<cmd>Aider drop<cr>',         desc = 'Drop File' },
    --         { '<leader>ar', '<cmd>Aider add readonly<cr>', desc = 'Add Read-Only' },
    --         { '<leader>aR', '<cmd>Aider reset<cr>',        desc = 'Reset Session' },
    --     },
    --     dependencies = {
    --         'folke/snacks.nvim',
    --     },
    --     config = function()
    --         require('nvim_aider').setup({
    --             auto_reload = true,
    --         })
    --     end,
    -- },
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
    --                     -- end_point = 'https://openrouter.ai/api/v1/chat/completions',
    --                     -- api_key = 'OPENROUTER_API_KEY',
    --                     end_point = 'https://api.x.ai/v1/chat/completions',
    --                     api_key = 'XAI_API_KEY',
    --                     model = 'grok-code-fast-1',
    --                     name = 'Openrouter',
    --                     optional = {
    --                         stop = nil,
    --                         max_tokens = nil,
    --                     },
    --                 }
    --             },
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
