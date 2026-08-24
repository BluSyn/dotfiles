-- ZSA Voyager + MacBook Cmd layout, mapped onto Omarchy/Hyprland.
--
-- Firmware in ~/dotfiles/zsa_voyager stays unchanged. This file makes Linux
-- interpret the same HID the Mac Mini already understands:
--   GUI  (home-row F/J, MacBook Cmd)  = Mac Cmd
--   ALT  (home-row D/K, MacBook Opt)  = Mac Option
--   CTRL (home-row S/L, MacBook Ctrl) = Ctrl (tmux prefix C-a, etc.)
--
-- Space-hold is Voyager layer 1. Those keys already emit real combos
-- (Cmd+C/V, Cmd+Shift+4, Cmd+`, Opt+Left/Right, Opt+Backspace, media keys).
-- We only bind the ones macOS implements in the OS that Linux does not.

-- See current bindings: omarchy menu keybindings --print

-- ---------------------------------------------------------------------------
-- Helpers (same send_key_state split as default/hypr/bindings/clipboard.lua)
-- ---------------------------------------------------------------------------

local function send_shortcut_once(mods, key)
  return function()
    local spec = { key = key, state = "down" }
    if mods and mods ~= "" then
      spec.mods = mods
    end
    hl.dispatch(hl.dsp.send_key_state(spec))
    hl.timer(function()
      local up = { key = key, state = "up" }
      if mods and mods ~= "" then
        up.mods = mods
      end
      hl.dispatch(hl.dsp.send_key_state(up))
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

-- Cmd+key -> Ctrl+key for GUI apps. Terminals keep using real Ctrl
-- (tmux prefix, suspend, EOF, flow control).
local function cmd_as_ctrl(key, terminal_mods, terminal_key)
  return function()
    if active_window_is_terminal() then
      if terminal_key then
        send_shortcut_once(terminal_mods, terminal_key)()
      end
      return
    end
    send_shortcut_once("CTRL", key)()
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

-- ---------------------------------------------------------------------------
-- Free Super so it can act as Mac Cmd.
-- Previous Omarchy action is noted on each line.
-- ---------------------------------------------------------------------------

-- Tiling / window ops that stole Cmd+letter app shortcuts.
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

-- Super+1-9 were workspaces. Voyager Cmd+symbol-row emits Cmd+number for
-- browser tabs; Super+Shift+3/4 are Mac screenshots.
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
end

-- Super+Ctrl+1-9 were bar-panel toggles; reused as move-to-workspace.
for panel = 1, 9 do
  hl.unbind("SUPER + CTRL + code:" .. tostring(panel + 9))
end

hl.unbind("SUPER + TAB") -- was: next workspace (Cmd+Tab is app switcher)
hl.unbind("SUPER + SHIFT + TAB") -- was: previous workspace
hl.unbind("SUPER + CTRL + TAB") -- was: former workspace

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

hl.unbind("SUPER + BACKSPACE") -- was: transparency (Cmd+Backspace is delete-to-BOL)
hl.unbind("SUPER + SHIFT + BACKSPACE")
hl.unbind("SUPER + CTRL + BACKSPACE")

hl.unbind("SUPER + code:20") -- minus: was window resize (Cmd+- is zoom out)
hl.unbind("SUPER + code:21") -- equal: was window resize (Cmd++ is zoom in)
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

hl.unbind("SUPER + SLASH") -- was: monitor scale (Cmd+/ is help)
hl.unbind("SUPER + ALT + SLASH")

-- Always-on app launchers that collide with Mac Cmd+Shift chords.
hl.unbind("SUPER + SHIFT + F") -- was: file manager (Cmd+Shift+F is find)
hl.unbind("SUPER + SHIFT + N") -- was: editor (Cmd+Shift+N is new window)
hl.unbind("SUPER + SHIFT + B") -- was: browser (Cmd+Shift+B is bookmarks)

-- ---------------------------------------------------------------------------
-- Voyager layer 1 (space-hold) + stock Mac OS shortcuts
-- ---------------------------------------------------------------------------

-- Dedicated layer-1 key sends Cmd+Shift+4; MacBook Cmd+Shift+3/4 too.
-- (was: move window to workspace 3/4)
o.bind("SUPER + SHIFT + code:13", "Screenshot selection", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + code:12", "Screenshot display", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + code:14", "Capture menu", "omarchy-menu toggle capture")

-- Layer 1 top-right: RGUI(grave). Cycle other windows of the same app.
o.bind("SUPER + code:49", "Cycle windows of the same app", cycle_same_class(false))
o.bind("SUPER + SHIFT + code:49", "Cycle windows of the same app (reverse)", cycle_same_class(true))

-- Layer 1 Opt+Backspace: delete word. Fish already wants Alt+Backspace;
-- GTK/Qt want Ctrl+Backspace.
o.bind("ALT + BACKSPACE", "Delete word", function()
  if active_window_is_terminal() then
    send_shortcut_once("ALT", "BACKSPACE")()
  else
    send_shortcut_once("CTRL", "BACKSPACE")()
  end
end)

-- Layer 1 Opt+Left/Right: word jump (Mac Option). Linux browsers otherwise
-- treat Alt+Left as Back; browser Back is rebound to Cmd+[ below.
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

-- MAC_LOCK on Voyager emits consumer 0x19E. Bind common lock keysyms too.
o.bind("XF86ScreenSaver", "Lock system", "omarchy-system-lock", { locked = true })
o.bind("XF86Sleep", "Lock system", "omarchy-system-lock", { locked = true })
-- Mac Ctrl+Cmd+Q
o.bind("SUPER + CTRL + Q", "Lock system", "omarchy-system-lock", { locked = true })

-- ---------------------------------------------------------------------------
-- Super as Cmd: send Ctrl+key to GUI apps
-- Clipboard Super+C/V/X is already provided by Omarchy. Do not unbind those.
-- ---------------------------------------------------------------------------

-- Skip in terminals: tmux prefix, EOF, reverse-search, flow control, suspend.
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

-- Physically held SUPER is stripped by send_key_state (explicit mods only).
o.bind("SUPER + SHIFT + F", "Find in files", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "F")()
  end
end)
o.bind("SUPER + SHIFT + G", "Find previous", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "G")()
  end
end)
o.bind("SUPER + SHIFT + N", "New window", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "N")()
  end
end)
o.bind("SUPER + SHIFT + T", "Reopen tab", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "T")()
  end
end)
o.bind("SUPER + SHIFT + Z", "Redo", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "Z")()
  end
end)
o.bind("SUPER + SHIFT + B", "Bookmarks bar", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "B")()
  end
end)

-- Cmd+W: close tab in GUI, close window in terminals (Mac Terminal Cmd+W).
o.bind("SUPER + W", "Close tab / window", function()
  if active_window_is_terminal() then
    hl.dispatch(hl.dsp.window.close())
  else
    send_shortcut_once("CTRL", "W")()
  end
end)
-- Cmd+Shift+W: close window. Cmd+Q: quit/close.
o.bind("SUPER + SHIFT + W", "Close window", hl.dsp.window.close())
o.bind("SUPER + Q", "Quit window", hl.dsp.window.close())

o.bind("SUPER + comma", "Preferences", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL", "comma")()
  end
end)

-- Cmd+1-9 / Cmd+0: tabs and zoom reset (Voyager Cmd+symbol-row).
for n = 1, 10 do
  local key = "code:" .. tostring(n + 9)
  o.bind("SUPER + " .. key, "App tab " .. (n % 10), cmd_as_ctrl(tostring(n % 10)))
end

-- Cmd+- / Cmd+= zoom. Inject minus/equal by keysym.
o.bind("SUPER + code:20", "Zoom out", cmd_as_ctrl("minus"))
o.bind("SUPER + code:21", "Zoom in", cmd_as_ctrl("equal"))
o.bind("SUPER + SHIFT + code:21", "Zoom in", function()
  if not active_window_is_terminal() then
    send_shortcut_once("CTRL + SHIFT", "equal")()
  end
end)

-- Cmd+Left/Right: line start/end. Cmd+Up/Down: document start/end.
o.bind("SUPER + LEFT", "Line start", send_shortcut_once(nil, "HOME"))
o.bind("SUPER + RIGHT", "Line end", send_shortcut_once(nil, "END"))
o.bind("SUPER + UP", "Document start", send_shortcut_once("CTRL", "HOME"))
o.bind("SUPER + DOWN", "Document end", send_shortcut_once("CTRL", "END"))

-- Cmd+[ / Cmd+]: back/forward in browsers (Linux uses Alt+arrows).
o.bind("SUPER + code:34", "Back", send_shortcut_once("ALT", "LEFT"))
o.bind("SUPER + code:35", "Forward", send_shortcut_once("ALT", "RIGHT"))

-- Cmd+Backspace: delete to start of line.
o.bind("SUPER + BACKSPACE", "Delete to start of line", function()
  send_shortcut_once("SHIFT", "HOME")()
  hl.timer(function()
    send_shortcut_once(nil, "BACKSPACE")()
  end, { timeout = 60, type = "oneshot" })
end)

-- Cmd+Shift+/: help. Put the Omarchy keybind cheatsheet here.
o.bind("SUPER + SHIFT + SLASH", "Keybindings", "omarchy-menu-keybindings")

-- Cmd+H hide, Cmd+M minimize -> scratchpad.
o.bind("SUPER + H", "Hide window (scratchpad)", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + M", "Minimize window (scratchpad)", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + CTRL + M", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))

-- Cmd+Tab: cycle windows (closest thing to the Mac app switcher).
o.bind("SUPER + TAB", "Next window", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end)
o.bind("SUPER + SHIFT + TAB", "Previous window", function()
  hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- ---------------------------------------------------------------------------
-- Window manager (keys Mac does not use for apps)
-- ---------------------------------------------------------------------------

-- macOS Spaces: Control+number and Control+Left/Right.
-- Voyager reaches Ctrl+number as Ctrl+Shift+symbol (firmware strips Shift).
for workspace = 1, 9 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("CTRL + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  -- Cmd+Ctrl+number: move window (Voyager: F+S+symbol-row).
  o.bind("SUPER + CTRL + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

o.bind("CTRL + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("CTRL + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Ctrl+Cmd+F: fullscreen (Mac).
o.bind("SUPER + CTRL + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + CTRL + SHIFT + F", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

-- Directional focus/move without eating Cmd or Option+arrows.
-- Voyager: hold S (Ctrl) + D (Alt) + H/J/K/L.
o.bind("CTRL + ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("CTRL + ALT + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("CTRL + ALT + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("CTRL + ALT + L", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("CTRL + ALT + SHIFT + H", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("CTRL + ALT + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("CTRL + ALT + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("CTRL + ALT + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

-- File manager: keep the cwd variant; main launcher is Cmd+Space.
-- SUPER + ALT + SHIFT + F remains Omarchy's "File manager (cwd)".

-- Notifications (moved off Cmd+,).
o.bind("SUPER + CTRL + comma", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("SUPER + CTRL + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
