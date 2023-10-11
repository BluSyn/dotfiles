vim.g.mapleader = " "

-- move selection up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- merge next link
vim.keymap.set("n", "J", "mzJ`z")

-- faster page nav with viewport centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- fast save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>qqq", ":bufdo q!<CR>")

-- delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- escape insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- \p/
vim.keymap.set("n", "Q", "<nop>")

-- lsp finder
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format)

-- comment/uncomment (nvim-comment)
vim.keymap.set("v", "<leader>/", ":'<,'>CommentToggle<CR>")

-- location jump
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- next / previous buffers
vim.keymap.set("n", "<leader>p", "<C-o>")
vim.keymap.set("n", "<leader>n", "<C-i>")

-- replace word under cursor
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- mark file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- for funsies
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

