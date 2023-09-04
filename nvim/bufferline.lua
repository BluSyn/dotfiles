vim.opt.termguicolors = true
require("bufferline").setup {
    options = {
        diagnostics = "nvim_lsp",
        tab_size = 20,
        offsets = {{filetype = "NvimTree", text = "File Explore", text_align = "left"}}
    }
}

vim.keymap.set("n", "<leader>]", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<leader>[", ":BufferLineCyclePrev<CR>")
-- Close current buffer and move to next
vim.keymap.set("n", "<leader>.", ":bw<CR> <Bar> :bnext<CR>")
