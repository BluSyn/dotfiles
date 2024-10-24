require('mylua.set')
require('mylua.remap')

-- Install lazy if not installed
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('mylua.lazy')

-- Create new file in netrw with 'a'
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'a', ':lua CreateFile()<CR>', { noremap = true, silent = true })
    end,
})

function CreateFile()
    -- Get the current directory shown in netrw (current buffer dir)
    local current_dir = vim.fn.expand('%:p:h')

    -- Get the full path to the new file
    local new_file = vim.fn.input('New file: ', current_dir .. '/')

    if new_file ~= "" then
        vim.cmd('e ' .. new_file)
        vim.cmd('w')
    end
end
