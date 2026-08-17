-- Seamless <C-h/j/k/l> across Neovim splits and herdr panes.
-- In herdr: move nvim splits first; at an edge, hand off to herdr.
-- Outside herdr: fall back to tmux.nvim (if loaded) or plain wincmd.

local M = {}

local tmux_move = {
  left = "move_left",
  down = "move_bottom",
  up = "move_top",
  right = "move_right",
}

function M.nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return
  end

  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then
      herdr = "herdr"
    end
    vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--pane", vim.env.HERDR_PANE_ID })
    return
  end

  if vim.env.TMUX and vim.env.TMUX ~= "" then
    local ok, tmux = pcall(require, "tmux")
    local fn = tmux_move[dir]
    if ok and fn and tmux[fn] then
      tmux[fn]()
    end
  end
end

function M.setup()
  local function map(lhs, wincmd, dir, desc)
    vim.keymap.set({ "n", "v" }, lhs, function()
      M.nav(wincmd, dir)
    end, { silent = true, noremap = true, desc = desc })
    vim.keymap.set("t", lhs, function()
      vim.cmd("stopinsert")
      M.nav(wincmd, dir)
    end, { silent = true, noremap = true, desc = desc })
  end

  map("<C-h>", "h", "left", "Navigate left (nvim/herdr)")
  map("<C-j>", "j", "down", "Navigate down (nvim/herdr)")
  map("<C-k>", "k", "up", "Navigate up (nvim/herdr)")
  map("<C-l>", "l", "right", "Navigate right (nvim/herdr)")
end

return M
