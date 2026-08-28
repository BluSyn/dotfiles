-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Built-in Apple trackpad (MacBookPro18,1 SPI / hid-magicmouse).
-- Keyboard layout is left at Omarchy's default (US, Cmd/Super unswapped) so
-- the Voyager's GUI key and the MacBook Cmd key both stay Super.
--
-- Pointer speed is input.sensitivity (libinput accel speed, -1.0..1.0).
-- scroll_factor only scales two-finger scroll; leave it at 0.7.
--
-- Omarchy defaults tap_to_click=false on Asahi to cut palm taps while typing.
-- This Force Touch pad has no mechanical click. linux-asahi reports press as
-- BTN_LEFT from firmware, but the Taptic Engine is not driven (no haptic
-- feature reports, hid-magicmouse has no actuator path). Keep tap-to-click
-- so a light tap is still a click. disable_while_typing limits palm taps.
hl.config({
	input = {
		-- Click to focus: hovering a window does not steal keyboard focus.
		-- 1 (Omarchy default) focuses on mouse move; 2 keeps keyboard until click.
		follow_mouse = 2,
		-- Pointer speed only (libinput accel speed, -1.0..1.0). Default 0 is slow
		-- on this 16" HiDPI pad; 0.6 is a clear bump, 1.0 is max. Does not change
		-- two-finger scroll (that's scroll_factor below).
		sensitivity = 0.6,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
			tap_and_drag = true,
			clickfinger_behavior = true,
			disable_while_typing = true,
			scroll_factor = 0.7,
		},
	},
})

-- Same pointer speed on the built-in pad if a USB mouse is added later.
hl.device({
	name = "apple-spi-trackpad",
	sensitivity = 0.6,
})

-- Three-finger swipe between workspaces (Mac Spaces on the built-in trackpad).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
