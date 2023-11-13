-- For treemux (nvim+tmux) plugin: https://github.com/kiyoon/treemux
-- nvim-tree recommends disabling netrw, VIM's built-in file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Remove the white status bar below
vim.o.laststatus = 0

-- True colour support
vim.o.termguicolors = true

vim.o.cursorline = true
vim.opt.guicursor = ""

-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

local function nvim_tree_on_attach(bufnr)
    local api = require "nvim-tree.api"
    local nt_remote = require "nvim_tree_remote"

    local function opts(desc)
        return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true
        }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.set("n", "u", api.tree.change_root_to_node, opts "Dir up")
    vim.keymap.set("n", ";", api.node.show_info_popup, opts "Show info popup")
    vim.keymap.set("n", "<CR>", nt_remote.tabnew, opts "Open in treemux")
    vim.keymap.set("n", "v", nt_remote.vsplit, opts "Vsplit in treemux")
end

local lazy = require('mylua.lazy')
local tmuxtree_lazy = {
    {
        "kiyoon/tmuxsend.vim",
        keys = {
            { "-", "<Plug>(tmuxsend-smart)", mode = { "n", "x" } },
            { "_", "<Plug>(tmuxsend-plain)", mode = { "n", "x" } },
            { "<space>-", "<Plug>(tmuxsend-uid-smart)", mode = { "n", "x" } },
            { "<space>_", "<Plug>(tmuxsend-uid-plain)", mode = { "n", "x" } },
            { "<C-_>", "<Plug>(tmuxsend-tmuxbuffer)", mode = { "n", "x" } },
        },
    },
    "kiyoon/nvim-tree-remote.nvim",

    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            local nvim_tree = require "nvim-tree"

            nvim_tree.setup {
                on_attach = nvim_tree_on_attach,
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                },
                renderer = {
                    icons = {
                        glyphs = {
                            default = "",
                            symlink = "",
                            folder = {
                                arrow_open = "",
                                arrow_closed = "",
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                                symlink_open = "",
                            },
                            git = {
                                unstaged = "",
                                staged = "S",
                                unmerged = "",
                                renamed = "➜",
                                untracked = "U",
                                deleted = "",
                                ignored = "◌",
                            },
                        },
                    },
                },
                diagnostics = {
                    enable = true,
                    show_on_dirs = true,
                    icons = {
                        hint = "",
                        info = "",
                        warning = "",
                        error = "",
                    },
                },
                view = {
                    width = 30,
                    side = "left",
                },
                git = {
                    enable = true,
                    ignore = false,
                },
            }
        end,
    },
}

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

require('lazy').setup(TableConcat(lazy, tmuxtree_lazy))
