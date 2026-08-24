-- Additive binds for ZSA Voyager + Raycast Hyper. Omarchy Super window
-- keys stay at their defaults (Cmd+arrows, Cmd+W, Cmd+J/K/L, workspaces, …).
--
-- Voyager HID (firmware unchanged):
--   GUI  (F/J, MacBook Cmd) = Super
--   Hyper (Esc-hold / ALL_T) = Ctrl+Alt+Shift+Super
--
-- Raycast export: ~/Downloads/hotkeys.md
-- View binds: omarchy menu keybindings --print

local hyper = "SUPER + CTRL + ALT + SHIFT"

-- Undo a previous snap helper that set column_width = 1.0 for the session
-- (new windows spawned full-width and shoved neighbors off the tape).
-- Hyprland defaults: one window fills the screen; extra windows are 50% columns.
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 0.5,
  },
})

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function send_shortcut_once(mods, key)
  local m = mods
  if m == nil or m == "" then
    m = " "
  end
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = m, key = key, state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = m, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end
  return false
end

local function cycle_same_class(backwards)
  return function()
    local current = hl.get_active_window()
    if not current then
      return
    end

    local same = {}
    for _, window in ipairs(hl.get_windows({ mapped = true }) or {}) do
      if window.class == current.class then
        same[#same + 1] = window
      end
    end

    if #same < 2 then
      hl.dispatch(hl.dsp.window.cycle_next({ next = not backwards }))
      hl.dispatch(hl.dsp.window.bring_to_top())
      return
    end

    table.sort(same, function(a, b)
      return (a.focus_history_id or 999) < (b.focus_history_id or 999)
    end)

    local target = backwards and same[#same] or same[2]
    if target then
      hl.dispatch(hl.dsp.focus({ window = target }))
      hl.dispatch(hl.dsp.window.bring_to_top())
    end
  end
end

local function reserved_sides(mon)
  local r = mon.reserved
  if type(r) == "table" and (r.top ~= nil or r.left ~= nil) then
    return r.left or 0, r.top or 0, r.right or 0, r.bottom or 0
  end
  if type(r) == "table" then
    return r[1] or 0, r[2] or 0, r[3] or 0, r[4] or 0
  end
  return 0, 0, 0, 0
end

local function vec_xy(value, fallback_x, fallback_y)
  if type(value) == "table" then
    return value.x or value[1] or fallback_x, value.y or value[2] or fallback_y
  end
  return fallback_x, fallback_y
end

local function monitor_workarea(mon)
  local scale = tonumber(mon.scale) or 1
  local x, y = vec_xy(mon.position, mon.x or 0, mon.y or 0)
  local w, h = vec_xy(mon.size, mon.width or 0, mon.height or 0)
  if scale > 1.01 and w > 2400 then
    x, y, w, h = x / scale, y / scale, w / scale, h / scale
  end
  local left, top, right, bottom = reserved_sides(mon)
  return {
    x = x + left,
    y = y + top,
    w = math.max(1, w - left - right),
    h = math.max(1, h - top - bottom),
  }
end

local function win_width(win)
  local size = win and win.size
  if type(size) == "table" then
    return size.x or size[1] or 0
  end
  return 0
end

local function win_x(win)
  local at = win and win.at
  if type(at) == "table" then
    return at.x or at[1] or 0
  end
  return 0
end

local function tile_active()
  local win = hl.get_active_window()
  if not win then
    return nil
  end
  if win.fullscreen and win.fullscreen ~= 0 then
    hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
    win = hl.get_active_window() or win
  end
  if win.floating then
    hl.dispatch(hl.dsp.window.float({ action = "disable" }))
    win = hl.get_active_window() or win
  end
  return win
end

-- Dwindle/master: grow/shrink this node; the sibling keeps the rest of the split.
local function resize_split_width(width_frac)
  local win = hl.get_active_window()
  local mon = (win and win.monitor) or hl.get_active_monitor()
  if not win or not mon then
    return
  end

  local target = math.floor(monitor_workarea(mon).w * width_frac + 0.5)
  local current = win_width(win)
  if math.abs(target - current) < 4 then
    return
  end

  local function apply(dx)
    hl.dispatch(hl.dsp.window.resize({ x = dx, y = 0, relative = true }))
  end

  local direction = nil
  apply(10)
  win = hl.get_active_window() or win
  local nxt = win_width(win)
  if nxt ~= current then
    direction = ((nxt - current) * 10 > 0) and 1 or -1
    current = nxt
  else
    apply(-10)
    win = hl.get_active_window() or win
    nxt = win_width(win)
    if nxt ~= current then
      direction = ((nxt - current) * -10 > 0) and 1 or -1
      current = nxt
    end
  end
  if not direction then
    return
  end

  for _ = 1, 6 do
    local delta = target - current
    if delta == 0 then
      break
    end
    apply(delta * direction)
    win = hl.get_active_window() or win
    nxt = win_width(win)
    if nxt == current then
      break
    end
    current = nxt
  end
end

local function place_on_side(side)
  local win = hl.get_active_window()
  local mon = (win and win.monitor) or hl.get_active_monitor()
  if not win or not mon or not side then
    return
  end
  local mid = monitor_workarea(mon).x + monitor_workarea(mon).w / 2
  if side == "left" and win_x(win) >= mid - 20 then
    hl.dispatch(hl.dsp.window.swap({ direction = "l" }))
  elseif side == "right" and win_x(win) < mid - 20 then
    hl.dispatch(hl.dsp.window.swap({ direction = "r" }))
  end
end

local function tiled_on_active_workspace()
  local ws = hl.get_active_workspace()
  local out = {}
  for _, win in ipairs(hl.get_workspace_windows(ws) or {}) do
    if not win.floating then
      out[#out + 1] = win
    end
  end
  return out
end

-- Tiled snap: current column gets width_frac; siblings share the rest so the
-- tape stays ≤ 100% of the view (no horizontal overflow).
-- side is "left" / "right" / nil (keep current side).
local function snap_tiled(width_frac, side)
  return function()
    if not tile_active() then
      return
    end

    local ws = hl.get_active_workspace()
    local layout = (ws and ws.tiled_layout) or ""
    local n = #tiled_on_active_workspace()

    if layout == "scrolling" then
      if n >= 2 then
        local others = (1 - width_frac) / (n - 1)
        hl.dispatch(hl.dsp.layout("colresize all " .. string.format("%.3f", others)))
        hl.dispatch(hl.dsp.layout("colresize " .. string.format("%.3f", width_frac)))
      else
        -- One tiled window already fills the view; Hyper+Z is fullscreen.
        hl.dispatch(hl.dsp.layout("colresize " .. string.format("%.3f", width_frac)))
      end
    else
      resize_split_width(width_frac)
    end

    place_on_side(side)
    if layout == "scrolling" then
      hl.dispatch(hl.dsp.layout("fit_into_view"))
    end
  end
end

-- Hyper+Z: fill the usable view (keep the Omarchy bar and client chrome).
-- True fullscreen (hides the bar / Chrome tabs) stays on Super+F.
local function toggle_zoom()
  local win = hl.get_active_window()
  if not win then
    return
  end
  if win.floating then
    hl.dispatch(hl.dsp.window.float({ action = "disable" }))
  end
  -- 2 = client/compositor fullscreen. Drop that first so maximize can apply.
  if win.fullscreen == 2 then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "unset" }))
  end
  hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
end

local function restore_tiled()
  tile_active()
  local ws = hl.get_active_workspace()
  if ws and ws.tiled_layout == "scrolling" then
    local n = math.max(1, #tiled_on_active_workspace())
    hl.dispatch(hl.dsp.layout("colresize all " .. string.format("%.3f", 1 / n)))
    hl.dispatch(hl.dsp.layout("fit_into_view"))
  else
    resize_split_width(0.5)
  end
end

-- ---------------------------------------------------------------------------
-- Voyager layer 1 (space-hold) — only chords Omarchy does not already provide
-- ---------------------------------------------------------------------------

-- Dedicated screenshot key sends Cmd+Shift+4 (Mac). This replaces Omarchy's
-- Super+Shift+3/4 (move window to workspace 3/4). Super+Shift+1/2/5–0 stay.
hl.unbind("SUPER + SHIFT + code:12")
hl.unbind("SUPER + SHIFT + code:13")
o.bind("SUPER + SHIFT + code:13", "Screenshot selection", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + code:12", "Screenshot display", "omarchy-capture-screenshot fullscreen")

-- Layer 1 Cmd+` : other windows of this app. Super+grave is unbound by default.
o.bind("SUPER + code:49", "Cycle windows of the same app", cycle_same_class(false))
o.bind("SUPER + SHIFT + code:49", "Cycle windows of the same app (reverse)", cycle_same_class(true))

-- Layer 1 Opt+Backspace / Opt+Left / Opt+Right (Mac word editing).
o.bind("ALT + BACKSPACE", "Delete word", function()
  if active_window_is_terminal() then
    send_shortcut_once("ALT", "BACKSPACE")()
  else
    send_shortcut_once("CTRL", "BACKSPACE")()
  end
end)
o.bind("ALT + LEFT", "Word left", function()
  if active_window_is_terminal() then
    send_shortcut_once("ALT", "LEFT")()
  else
    send_shortcut_once("CTRL", "LEFT")()
  end
end)
o.bind("ALT + RIGHT", "Word right", function()
  if active_window_is_terminal() then
    send_shortcut_once("ALT", "RIGHT")()
  else
    send_shortcut_once("CTRL", "RIGHT")()
  end
end)

-- ---------------------------------------------------------------------------
-- Raycast Hyper (Voyager Esc-hold) — apps
-- ---------------------------------------------------------------------------

o.bind(hyper .. " + C", "Browser", "omarchy-launch-or-focus chromium omarchy-launch-browser")
o.bind(hyper .. " + T", "Terminal", "omarchy-launch-or-focus '(foot|kitty|Alacritty|ghostty|com.mitchellh.ghostty)' omarchy-launch-terminal")
o.bind(hyper .. " + X", "Calculator", { launch = "gnome-calculator", focus = "calculator" })
o.bind(hyper .. " + P", "Spotify", "omarchy-launch-or-focus-webapp Spotify https://open.spotify.com")
o.bind(hyper .. " + A", "Calendar", "omarchy-launch-or-focus-webapp Calendar https://calendar.google.com")
o.bind(hyper .. " + M", "Gmail", "omarchy-launch-or-focus-webapp Gmail https://mail.google.com")
o.bind(hyper .. " + I", "Messages", "omarchy-launch-or-focus-webapp Messages https://messages.google.com/web/conversations")
o.bind(hyper .. " + L", "Linear", "omarchy-launch-or-focus-webapp Linear https://linear.app")
o.bind(hyper .. " + S", "Slack", "omarchy-launch-or-focus-webapp Slack https://app.slack.com")
o.bind(hyper .. " + N", "Notes", "omarchy-launch-or-focus-webapp Keep https://keep.google.com")
o.bind(hyper .. " + RETURN", "Quick AI", "omarchy-agent")
o.bind(hyper .. " + Y", "Ask Grok", "omarchy-launch-or-focus-webapp Grok https://grok.com")
o.bind(hyper .. " + O", "Ask about clipboard image", "omarchy-launch-or-focus-webapp Grok https://grok.com")
o.bind(hyper .. " + F", "Search Google", "omarchy-launch-or-focus-webapp Google https://www.google.com")
o.bind(hyper .. " + H", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- ---------------------------------------------------------------------------
-- Raycast Hyper — window sizes (stay tiled; siblings shrink to fit)
-- ---------------------------------------------------------------------------

o.bind(hyper .. " + TAB", "Left half", snap_tiled(0.5, "left"))
o.bind(hyper .. " + code:48", "Right half", snap_tiled(0.5, "right"))
o.bind(hyper .. " + LEFT", "First two thirds", snap_tiled(2 / 3, "left"))
o.bind(hyper .. " + RIGHT", "Last third", snap_tiled(1 / 3, "right"))
o.bind(hyper .. " + SPACE", "Center two thirds", snap_tiled(2 / 3, nil))
o.bind(hyper .. " + code:51", "Last two thirds", snap_tiled(2 / 3, "right"))
o.bind(hyper .. " + code:20", "Left 60", snap_tiled(0.6, "left"))
o.bind(hyper .. " + code:21", "Right 40", snap_tiled(0.4, "right"))
o.bind(hyper .. " + Z", "Toggle maximize (keep bar)", toggle_zoom)
o.bind(hyper .. " + B", "Restore", restore_tiled)

-- Repair this session: equalize any columns left wider than the view.
do
  local ws = hl.get_active_workspace()
  if ws and ws.tiled_layout == "scrolling" then
    local n = math.max(1, #tiled_on_active_workspace())
    hl.dispatch(hl.dsp.layout("colresize all " .. string.format("%.3f", 1 / n)))
    hl.dispatch(hl.dsp.layout("fit_into_view"))
  end
end
