-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Built-in Apple trackpad: Mac-like direction and two-finger click.
-- Keyboard layout is left at Omarchy's default (US, Cmd/Super unswapped) so
-- the Voyager's GUI key and the MacBook Cmd key both stay Super.
hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})

-- Three-finger swipe between workspaces (Mac Spaces on the built-in trackpad).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
