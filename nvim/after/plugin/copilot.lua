require("copilot").setup({
    suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
            accept = "<S-CR>",
            accept_word = false,
            accept_line = false,
            -- next = "<M-]>",
            -- prev = "<M-[>",
            -- dismiss = "<C-]>",
        },
    }
})
