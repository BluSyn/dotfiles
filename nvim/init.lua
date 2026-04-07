-- Based on: https://github.com/ThePrimeagen/init.lua
require('mylua')

local ghostcalc = require("plugins.ghostcalc")
ghostcalc.setup()
vim.keymap.set('n', '<leader>cc', ghostcalc.toggle, { desc = "Toggle Calc" })

vim.opt.autoread = true
