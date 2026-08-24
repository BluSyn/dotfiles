-- ZSA Voyager + MacBook Cmd, plus Raycast Hyper hotkeys from the Mac Mini.
--
-- Firmware in ~/dotfiles/zsa_voyager is unchanged. HID meaning:
--   GUI  (home-row F/J, MacBook Cmd)  = Mac Cmd  = Super
--   ALT  (home-row D/K, MacBook Opt)  = Mac Option
--   CTRL (home-row S/L, MacBook Ctrl) = Ctrl
--   Hyper (Esc-hold / ALL_T)          = Ctrl+Alt+Shift+Cmd
--
-- Space-hold is Voyager layer 1. Raycast used Hyper+letter for apps and
-- window snaps; those chords are rebound here to Omarchy equivalents.
-- See ~/Downloads/hotkeys.md (Raycast export).
--
-- View binds: omarchy menu keybindings --print

local hyper = "SUPER + CTRL + ALT + SHIFT"

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- send_key_state requires a mods string even when there are none.
-- https://github.com/hyprwm/Hyprland/discussions/14417
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

-- Cmd+key -> Ctrl+key for GUI apps. Terminals keep real Ctrl (tmux, EOF, ...).
local function cmd_as_ctrl(key)
  return function()
    if active_window_is_terminal() then
      return
    end
    send_shortcut_once("CTRL", key)()
  end
end

local function cmd_as_ctrl_shift(key)
  return function()
    if active_window_is_terminal() then
      return
    end
    send_shortcut_once("CTRL + SHIFT", key)()
  end
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
    -- hyprctl monitors -j: [left, top, right, bottom] in layout units
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

-- Usable monitor rect in the same units as window.at / window.size.
local function monitor_workarea(mon)
  local scale = tonumber(mon.scale) or 1
  local x, y = vec_xy(mon.position, mon.x or 0, mon.y or 0)
  local w, h = vec_xy(mon.size, mon.width or 0, mon.height or 0)

  -- hyprctl reports physical pixels; window.at is logical.
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

-- Raycast-style snap: float the window and place it in a horizontal slice.
-- x_frac/width_frac are 0–1 of the usable monitor width; height is always full.
local function snap_window(x_frac, width_frac)
  return function()
    local win = hl.get_active_window()
    if not win then
      return
    end
    local mon = win.monitor or hl.get_active_monitor()
    if not mon then
      return
    end

    hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
    if not win.floating then
      hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    end

    local area = monitor_workarea(mon)
    local w = math.floor(area.w * width_frac + 0.5)
    local h = math.floor(area.h + 0.5)
    local x = math.floor(area.x + area.w * x_frac + 0.5)
    local y = math.floor(area.y + 0.5)

    hl.dispatch(hl.dsp.window.resize({ x = w, y = h, relative = false }))
    hl.dispatch(hl.dsp.window.move({ x = x, y = y, relative = false }))
  end
end

local function restore_window()
  hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
  local win = hl.get_active_window()
  if win and win.floating then
    hl.dispatch(hl.dsp.window.float({ action = "disable" }))
  end
end

-- ---------------------------------------------------------------------------
-- Free Super so it can act as Mac Cmd.
-- Previous Omarchy action is noted on each line.
-- ---------------------------------------------------------------------------

hl.unbind("SUPER + F") -- was: fullscreen (Cmd+F is find)
hl.unbind("SUPER + T") -- was: toggle floating (Cmd+T is new tab)
hl.unbind("SUPER + L") -- was: workspace layout (Cmd+L is address bar)
hl.unbind("SUPER + P") -- was: pseudo window (Cmd+P is print)
hl.unbind("SUPER + S") -- was: scratchpad (Cmd+S is save)
hl.unbind("SUPER + J") -- was: toggle split
hl.unbind("SUPER + O") -- was: pop window out (Cmd+O is open)
hl.unbind("SUPER + G") -- was: toggle grouping (Cmd+G is find next)
hl.unbind("SUPER + K") -- was: keybindings (Cmd+K is search/link)
hl.unbind("SUPER + W") -- was: close window (rebound as Cmd+W close-tab below)
hl.unbind("SUPER + ALT + S") -- was: move to scratchpad
hl.unbind("SUPER + ALT + F") -- was: full width
hl.unbind("SUPER + CTRL + F") -- was: tiled fullscreen (rebound as Ctrl+Cmd+F)
hl.unbind("SUPER + CTRL + Q") -- was: calculator (Ctrl+Cmd+Q is lock on Mac)
hl.unbind("SUPER + CTRL + SPACE") -- was: background switcher (Ctrl+Cmd+Space is emoji)

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
end

for panel = 1, 9 do
  hl.unbind("SUPER + CTRL + code:" .. tostring(panel + 9))
end

hl.unbind("SUPER + TAB") -- was: next workspace (Cmd+Tab is app switcher)
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + CTRL + TAB")

hl.unbind("SUPER + LEFT") -- was: focus left (Cmd+Left is line start)
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")

hl.unbind("SUPER + comma") -- was: dismiss notification (Cmd+, is preferences)
hl.unbind("SUPER + SHIFT + comma")
hl.unbind("SUPER + CTRL + comma")
hl.unbind("SUPER + ALT + comma")
hl.unbind("SUPER + SHIFT + ALT + comma")

hl.unbind("SUPER + BACKSPACE") -- was: transparency
hl.unbind("SUPER + SHIFT + BACKSPACE")
hl.unbind("SUPER + CTRL + BACKSPACE")

hl.unbind("SUPER + code:20") -- minus: was window resize (Cmd+- is zoom out)
hl.unbind("SUPER + code:21")
hl.unbind("SUPER + SHIFT + code:20")
hl.unbind("SUPER + SHIFT + code:21")
hl.unbind("SUPER + ALT + code:20")
hl.unbind("SUPER + ALT + code:21")
hl.unbind("SUPER + SHIFT + ALT + code:20")
hl.unbind("SUPER + SHIFT + ALT + code:21")
hl.unbind("SUPER + CTRL + code:20")
hl.unbind("SUPER + CTRL + code:21")
hl.unbind("SUPER + CTRL + SHIFT + code:20")
hl.unbind("SUPER + CTRL + SHIFT + code:21")

hl.unbind("SUPER + SLASH") -- was: monitor scale
hl.unbind("SUPER + ALT + SLASH")

hl.unbind("SUPER + SHIFT + F") -- was: file manager (Cmd+Shift+F is find)
hl.unbind("SUPER + SHIFT + N") -- was: editor (Cmd+Shift+N is new window)
hl.unbind("SUPER + SHIFT + B") -- was: browser (Cmd+Shift+B is bookmarks)

-- ---------------------------------------------------------------------------
-- Voyager layer 1 (space-hold) + stock Mac OS shortcuts
-- ---------------------------------------------------------------------------

o.bind("SUPER + SHIFT + code:13", "Screenshot selection", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + code:12", "Screenshot display", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + code:14", "Capture menu", "omarchy-menu toggle capture")

o.bind("SUPER + code:49", "Cycle windows of the same app", cycle_same_class(false))
o.bind("SUPER + SHIFT + code:49", "Cycle windows of the same app (reverse)", cycle_same_class(true))

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

o.bind("XF86ScreenSaver", "Lock system", "omarchy-system-lock", { locked = true })
o.bind("XF86Sleep", "Lock system", "omarchy-system-lock", { locked = true })
o.bind("SUPER + CTRL + Q", "Lock system", "omarchy-system-lock", { locked = true })

-- Raycast: Ctrl+Cmd+Space = emoji. Super+Ctrl+E stays as a second binding.
o.bind("SUPER + CTRL + SPACE", "Emoji", "omarchy-shell shell toggle omarchy.emojis")

-- ---------------------------------------------------------------------------
-- Super as Cmd: send Ctrl+key to GUI apps
-- Clipboard Super+C/V/X is already provided by Omarchy.
-- ---------------------------------------------------------------------------

o.bind("SUPER + A", "Select all", cmd_as_ctrl("A"))
o.bind("SUPER + B", "Bold / bookmarks", cmd_as_ctrl("B"))
o.bind("SUPER + D", "Bookmark / duplicate", cmd_as_ctrl("D"))
o.bind("SUPER + F", "Find", cmd_as_ctrl("F"))
o.bind("SUPER + G", "Find next", cmd_as_ctrl("G"))
o.bind("SUPER + I", "Italic / inspect", cmd_as_ctrl("I"))
o.bind("SUPER + K", "Search / link", cmd_as_ctrl("K"))
o.bind("SUPER + L", "Address bar / select line", cmd_as_ctrl("L"))
o.bind("SUPER + N", "New", cmd_as_ctrl("N"))
o.bind("SUPER + O", "Open", cmd_as_ctrl("O"))
o.bind("SUPER + P", "Print", cmd_as_ctrl("P"))
o.bind("SUPER + R", "Reload", cmd_as_ctrl("R"))
o.bind("SUPER + S", "Save", cmd_as_ctrl("S"))
o.bind("SUPER + T", "New tab", cmd_as_ctrl("T"))
o.bind("SUPER + U", "View source / underline", cmd_as_ctrl("U"))
o.bind("SUPER + Z", "Undo", cmd_as_ctrl("Z"))

o.bind("SUPER + SHIFT + F", "Find in files", cmd_as_ctrl_shift("F"))
o.bind("SUPER + SHIFT + G", "Find previous", cmd_as_ctrl_shift("G"))
o.bind("SUPER + SHIFT + N", "New window", cmd_as_ctrl_shift("N"))
o.bind("SUPER + SHIFT + T", "Reopen tab", cmd_as_ctrl_shift("T"))
o.bind("SUPER + SHIFT + Z", "Redo", cmd_as_ctrl_shift("Z"))
o.bind("SUPER + SHIFT + B", "Bookmarks bar", cmd_as_ctrl_shift("B"))

o.bind("SUPER + W", "Close tab / window", function()
  if active_window_is_terminal() then
    hl.dispatch(hl.dsp.window.close())
  else
    send_shortcut_once("CTRL", "W")()
  end
end)
o.bind("SUPER + SHIFT + W", "Close window", hl.dsp.window.close())
o.bind("SUPER + Q", "Quit window", hl.dsp.window.close())

o.bind("SUPER + comma", "Preferences", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL", "comma")()
  end
end)

for n = 1, 10 do
  local key = "code:" .. tostring(n + 9)
  o.bind("SUPER + " .. key, "App tab " .. (n % 10), cmd_as_ctrl(tostring(n % 10)))
end

o.bind("SUPER + code:20", "Zoom out", cmd_as_ctrl("minus"))
o.bind("SUPER + code:21", "Zoom in", cmd_as_ctrl("equal"))
o.bind("SUPER + SHIFT + code:21", "Zoom in", cmd_as_ctrl_shift("equal"))

-- Cmd+Left/Right: line start/end. Cmd+Up/Down: document start/end.
o.bind("SUPER + LEFT", "Line start", send_shortcut_once(" ", "HOME"))
o.bind("SUPER + RIGHT", "Line end", send_shortcut_once(" ", "END"))
o.bind("SUPER + UP", "Document start", send_shortcut_once("CTRL", "HOME"))
o.bind("SUPER + DOWN", "Document end", send_shortcut_once("CTRL", "END"))

o.bind("SUPER + code:34", "Back", send_shortcut_once("ALT", "LEFT"))
o.bind("SUPER + code:35", "Forward", send_shortcut_once("ALT", "RIGHT"))

o.bind("SUPER + BACKSPACE", "Delete to start of line", function()
  send_shortcut_once("SHIFT", "HOME")()
  hl.timer(function()
    send_shortcut_once(" ", "BACKSPACE")()
  end, { timeout = 60, type = "oneshot" })
end)

o.bind("SUPER + SHIFT + SLASH", "Keybindings", "omarchy-menu-keybindings")

o.bind("SUPER + H", "Hide window (scratchpad)", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + M", "Minimize window (scratchpad)", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + CTRL + M", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))

o.bind("SUPER + TAB", "Next window", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end)
o.bind("SUPER + SHIFT + TAB", "Previous window", function()
  hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- ---------------------------------------------------------------------------
-- Workspaces (Mac Spaces: Ctrl+number). Not Raycast; Voyager can emit these.
-- ---------------------------------------------------------------------------

for workspace = 1, 9 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("CTRL + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + CTRL + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

o.bind("CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

o.bind("SUPER + CTRL + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + CTRL + SHIFT + F", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

o.bind("CTRL + ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("CTRL + ALT + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("CTRL + ALT + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("CTRL + ALT + L", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("CTRL + ALT + SHIFT + H", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("CTRL + ALT + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("CTRL + ALT + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("CTRL + ALT + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

o.bind("SUPER + CTRL + comma", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("SUPER + CTRL + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")

-- ---------------------------------------------------------------------------
-- Raycast Hyper (Voyager Esc-hold) — apps
-- Mac app -> Omarchy equivalent already on this machine (no new packages).
-- ---------------------------------------------------------------------------

-- Hyper+C Chrome -> Chromium (default browser)
o.bind(hyper .. " + C", "Browser", "omarchy-launch-or-focus chromium omarchy-launch-browser")

-- Hyper+T WezTerm -> default terminal (foot)
o.bind(hyper .. " + T", "Terminal", "omarchy-launch-or-focus '(foot|kitty|Alacritty|ghostty|com.mitchellh.ghostty)' omarchy-launch-terminal")

-- Hyper+X Soulver -> gnome-calculator
o.bind(hyper .. " + X", "Calculator", { launch = "gnome-calculator", focus = "calculator" })

-- Hyper+P Spotify -> Spotify web (desktop client is not installed)
o.bind(hyper .. " + P", "Spotify", "omarchy-launch-or-focus-webapp Spotify https://open.spotify.com")

-- Hyper+A Calendar -> Google Calendar
o.bind(hyper .. " + A", "Calendar", "omarchy-launch-or-focus-webapp Calendar https://calendar.google.com")

-- Hyper+M Mailspring -> Gmail
o.bind(hyper .. " + M", "Gmail", "omarchy-launch-or-focus-webapp Gmail https://mail.google.com")

-- Hyper+I Messages -> Google Messages
o.bind(hyper .. " + I", "Messages", "omarchy-launch-or-focus-webapp Messages https://messages.google.com/web/conversations")

-- Hyper+L Linear
o.bind(hyper .. " + L", "Linear", "omarchy-launch-or-focus-webapp Linear https://linear.app")

-- Hyper+S Slack (web; desktop client is not installed)
o.bind(hyper .. " + S", "Slack", "omarchy-launch-or-focus-webapp Slack https://app.slack.com")

-- Hyper+N Notes -> Google Keep (no Notes/Omawrite/Obsidian install)
o.bind(hyper .. " + N", "Notes", "omarchy-launch-or-focus-webapp Keep https://keep.google.com")

-- Hyper+Return QuickAI -> default coding agent (grok)
o.bind(hyper .. " + RETURN", "Quick AI", "omarchy-agent")

-- Hyper+Y Ask ChatGPT -> Grok (default agent / closest installed AI)
o.bind(hyper .. " + Y", "Ask Grok", "omarchy-launch-or-focus-webapp Grok https://grok.com")

-- Hyper+O Ask Clipboard Image -> Grok (paste the image there)
o.bind(hyper .. " + O", "Ask about clipboard image", "omarchy-launch-or-focus-webapp Grok https://grok.com")

-- Hyper+F Search Google
o.bind(hyper .. " + F", "Search Google", "omarchy-launch-or-focus-webapp Google https://www.google.com")

-- Hyper+H Clipboard History
o.bind(hyper .. " + H", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")

-- ---------------------------------------------------------------------------
-- Raycast Hyper — window management (float + place, like Raycast on macOS)
-- ---------------------------------------------------------------------------

-- Hyper+Tab Left Half
o.bind(hyper .. " + TAB", "Left half", snap_window(0, 0.5))
-- Hyper+' Right Half
o.bind(hyper .. " + code:48", "Right half", snap_window(0.5, 0.5))
-- Hyper+Z Maximize
o.bind(hyper .. " + Z", "Maximize", snap_window(0, 1))
-- Hyper+B Restore (tile again)
o.bind(hyper .. " + B", "Restore", restore_window)
-- Hyper+Left First Two Thirds
o.bind(hyper .. " + LEFT", "First two thirds", snap_window(0, 2 / 3))
-- Hyper+Right Last Third
o.bind(hyper .. " + RIGHT", "Last third", snap_window(2 / 3, 1 / 3))
-- Hyper+Space Center Two Thirds
o.bind(hyper .. " + SPACE", "Center two thirds", snap_window(1 / 6, 2 / 3))
-- Hyper+\ Last Two Thirds
o.bind(hyper .. " + code:51", "Last two thirds", snap_window(1 / 3, 2 / 3))
-- Hyper+- Left 60
o.bind(hyper .. " + code:20", "Left 60", snap_window(0, 0.6))
-- Hyper+= Right 40
o.bind(hyper .. " + code:21", "Right 40", snap_window(0.6, 0.4))

-- Raycast Opt+Tab = Switch Windows: already ALT+TAB from Omarchy defaults.
-- Raycast Cmd+Space = Raycast: already SUPER+SPACE Omarchy menu.
