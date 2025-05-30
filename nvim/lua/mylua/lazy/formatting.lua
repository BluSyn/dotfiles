return {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local conform = require('conform')

        -- Helper function to check if Prettier is installed locally
        local function has_prettier()
            local project_root = vim.fn.getcwd()
            -- Check package.json for prettier dependency
            local package_json_path = project_root .. '/package.json'
            if vim.fn.filereadable(package_json_path) == 1 then
                local package_json = vim.fn.json_decode(vim.fn.readfile(package_json_path))
                local has_dep = (package_json.devDependencies and package_json.devDependencies.prettier)
                if has_dep then
                    return true
                end
            end
        end

        conform.setup({
            formatters_by_ft = {
                javascript = has_prettier() and { 'prettier' } or {},
                typescript = has_prettier() and { 'prettier' } or {},
                javascriptreact = has_prettier() and { 'prettier' } or {},
                typescriptreact = has_prettier() and { 'prettier' } or {},
                css = has_prettier() and { 'prettier' } or {},
                html = has_prettier() and { 'prettier' } or {},
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 500,
            },
        })
        vim.keymap.set({ 'n', 'v' }, '<leader>gp', function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 500,
            })
        end, { desc = 'Format file or range (in visual mode)' })
    end,
}
