-- Yes, backspace key is leader key (thumb cluster keys)
vim.g.mapleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)

-- remap c-a, as this is my tmux prefix
vim.keymap.set('n', '<C-q>', '<C-a>')
vim.keymap.set('v', '<C-q>', '<C-a>')
vim.keymap.set('v', 'g<C-q>', 'g<C-a>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = "Move selection down" })

vim.keymap.set('n', 'J', 'mzJ`z', { desc = "Combine next line" })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = "Page down" })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = "Page up" })

vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = "Quick Save" })
vim.keymap.set('n', '<leader>qqq', ':bufdo q!<CR>', { desc = "Quick Quit No Save" })

vim.keymap.set('v', '<leader>d', '"_d', { desc = "Delete without yanking" })

vim.keymap.set('i', '<C-c>', '<Esc>', { desc = "Escape Insert Mode" })

-- disable
vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, { desc = "Format File (LSP)" })

vim.keymap.set('n', '<leader>p', '<C-o>', { desc = "Previous Location" })
vim.keymap.set('n', '<leader>n', '<C-i>', { desc = "Next Location" })
vim.keymap.set('n', '<leader><leader>', '<C-^>', { desc = "Prevous Buffer" })

vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = "Mark File Executable" })
