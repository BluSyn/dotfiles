-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Built-in Apple trackpad (MacBookPro18,1 SPI / hid-magicmouse).
-- Keyboard layout is left at Omarchy's default (US, Cmd/Super unswapped) so
-- the Voyager's GUI key and the MacBook Cmd key both stay Super.
--
-- Pointer speed is input.sensitivity (libinput accel speed, -1.0..1.0).
-- scroll_factor only scales two-finger scroll; leave it at 0.7.
--
-- Palm rejection: libinput quirks in ~/dotfiles/libinput/ (copied to
-- /etc/libinput/local-overrides.quirks). AttrPalmSizeThreshold must stay 0;
-- 300 marked normal fingers as palms and killed the pad after reboot.
-- Pressure-based palm detection at 2000g remains.
--
-- Omarchy defaults tap_to_click=false on Asahi to cut palm taps while typing.
-- This Force Touch pad has no mechanical click (Taptic Engine is not driven).
-- Keep tap-to-click so a light tap is still a click; DWT limits palm taps.
hl.config({
	input = {
		-- Click to focus: hovering a window does not steal keyboard focus.
		-- 1 (Omarchy default) focuses on mouse move; 2 keeps keyboard until click.
		follow_mouse = 2,
		-- With follow_mouse=2, do not steal focus back when the pointer
		-- re-enters a window that was last focused from the keyboard.
		mouse_refocus = false,
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
	misc = {
		-- 3-finger clickfinger is middle click; do not paste at the caret.
		middle_click_paste = false,
	},
	gestures = {
		-- Accidental 3-finger palm swipe must not create an empty workspace
		-- (looks like every window closed). Need a committed swipe to switch.
		workspace_swipe_create_new = false,
		workspace_swipe_distance = 500,
		workspace_swipe_cancel_ratio = 0.7,
		workspace_swipe_min_speed_to_force = 0,
	},
})

-- Same pointer / tap policy on the built-in pad if a USB mouse is added later.
hl.device({
	name = "apple-spi-trackpad",
	sensitivity = 0.6,
	tap_to_click = true,
	tap_and_drag = true,
	disable_while_typing = true,
	clickfinger_behavior = true,
	natural_scroll = true,
})

-- Three-finger swipe between workspaces (Mac Spaces on the built-in trackpad).
-- Do not bind 3-finger down/close: palms on this pad look like a 3-finger swipe.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
