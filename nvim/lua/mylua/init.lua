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

-- open netrw in the directory of the current file
vim.keymap.set('n', '<leader>gd', ':Explore %:p:h<CR>', {
    noremap = true,
    silent = true,
    desc = 'Open netrw in the directory of the current file',
})

-- Create new file or directory in netrw with 'a'
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'a', ':lua CreateFileOrDir()<CR>', {
            noremap = true,
            silent = true,
            desc = 'Create new file or directory in netrw',
        })
    end,
})

function CreateFileOrDir()
    -- Get the current directory shown in netrw (current buffer dir)
    local current_dir = vim.b.netrw_curdir

    -- Get the full path to the new file or directory
    local new_path = vim.fn.input('New file or directory: ', current_dir .. '/')

    if new_path ~= "" then
        if new_path:match('.*/$') then
            -- Create directory if path ends with a slash
            vim.fn.mkdir(new_path, 'p')
        else
            -- Create nested directories if needed and then create the file
            local dir = vim.fn.fnamemodify(new_path, ':h')
            vim.fn.mkdir(dir, 'p')
            vim.cmd('e ' .. new_path)
            vim.cmd('w')
        end
    end
end
