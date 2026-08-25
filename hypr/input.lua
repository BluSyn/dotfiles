-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Built-in Apple trackpad (MacBookPro18,1 SPI / hid-magicmouse).
-- Keyboard layout is left at Omarchy's default (US, Cmd/Super unswapped) so
-- the Voyager's GUI key and the MacBook Cmd key both stay Super.
--
-- Omarchy defaults tap_to_click=false on Asahi to cut palm taps while typing.
-- Force Touch has no haptic driver in linux-asahi, so without tap-to-click
-- there is no reliable click. Keep disable-while-typing on to limit palms.
hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      tap_and_drag = true,
      clickfinger_behavior = true,
      disable_while_typing = true,
      scroll_factor = 0.4,
    },
  },
})

-- Three-finger swipe between workspaces (Mac Spaces on the built-in trackpad).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
