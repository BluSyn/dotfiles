vim.opt.guicursor = ''

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append('@-@')

-- increment letters
vim.opt.nrformats:append('alpha')

vim.opt.updatetime = 50

vim.opt.colorcolumn = '120'

vim.opt.list = true
vim.opt.listchars = {
    -- multispace = '∙',
    tab = '»·',
    trail = '•',
}

vim.opt.clipboard:append('unnamedplus')

vim.opt.showtabline = 0

-- Generally read .keymap files as C ones
vim.cmd [[autocmd BufNewFile,BufRead *.keymap setfiletype c]]

--vim.colorscheme = 'base16-tomorrow-night'
