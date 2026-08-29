-- Lua equivalent of hyprland.conf (Hyprland 0.55+).
-- hyprland.lua takes precedence over hyprland.conf when it exists.
-- See: https://wiki.hypr.land/Configuring/Start/ and https://alejandrominaya.github.io/hyprland-lua-docs

-----------------
-- MONITORS ----
-----------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local disable_builtin_screen = true
hl.monitor({
	output = "eDP-1",
	disabled = disable_builtin_screen,
	mode = "1920x1200@165",
	position = "0x0",
	scale = 1.5,
	bitdepth = 10,
}) -- DGPU
hl.monitor({
	output = "eDP-2",
	disabled = disable_builtin_screen,
	mode = "1920x1200@165",
	position = "0x0",
	scale = 1.5,
	bitdepth = 10,
}) -- IGPU
hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x-1200", scale = 1.25 })
hl.monitor({ output = "DP-2", mode = "2560x1440@165", position = "0x-1200", scale = 1.25 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x-1200", scale = 2.4 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "0x-1200", scale = 2.4 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x-1200", scale = 1.2, bitdepth = 10 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x-1200", scale = 1.2 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@120", position = "0x-1200", scale = 1.0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x-1200", scale = 1.2, bitdepth = 10, cm = "hdr", sdrbrightness = 1.1, sdrsaturation = 1.2 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@120", position = "0x-1200", scale = 1.2, bitdepth = 10, cm = "hdr", sdrbrightness = 1.1, sdrsaturation = 1.2 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1720x1440@144", position = "-1045x-1500", scale = 1.25 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3440x1440@100", position = "-1045x-1500", scale = 1.25, bitdepth = 10 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x-1200", scale = 2.4 })
-- hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@60", position = "0x-1200", scale = 1.6 })

---------------------
-- MY PROGRAMS ------
---------------------

-- Set programs that you use
local browser = "firefox"
local terminal = "kitty"
local fileManager = "dolphin"
-- local menu        = "hyprlauncher"
local noctalia = "qs -c noctalia-shell"
local menu = "qs -c noctalia-shell ipc call launcher toggle"
local controlCenter = "qs -c noctalia-shell ipc call controlCenter toggle"
local clipboardHistory = "qs -c noctalia-shell ipc call launcher clipboard"
local notificationDaemon = "dunst"

-------------------
-- AUTOSTART ------
-------------------

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	-- hl.exec_cmd(terminal)
	hl.exec_cmd("nm-applet &")
	hl.exec_cmd(noctalia)
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("kdeconnectd")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("kgpg")
	hl.exec_cmd("xrdb ~/.Xresources")

	hl.exec_cmd(browser, { workspace = 1 })
	hl.exec_cmd(terminal, { workspace = "special:terminal", no_initial_focus = true })
end)

------------------------------
-- ENVIRONMENT VARIABLES ----
------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_SIZE", "16")
-- hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("HYPRCURSER_THEME", "rose-pine-hyprcursor")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "qt6ct")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("GDK_SCALE", "1.5")

-----------------------
-- LOOK AND FEEL ------
-----------------------

-- unscale XWayland
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

-- https://wiki.hypr.land/Configuring/Variables/#general
hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 1,
		border_size = 1,

		col = {
			active_border = "rgb(98AF8E)",
			inactive_border = "rgb(415C4D)",
		},

		layout = "dwindle",

		resize_on_border = true,
		allow_tearing = false,
	},
})

-- https://wiki.hypr.land/Configuring/Variables/#decoration
hl.config({
	decoration = {
		rounding = 10,
		-- rounding_power = 2

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		-- https://wiki.hypr.land/Configuring/Variables/#blur
		blur = {
			enabled = true,
			size = 3,
			passes = 4,
			-- vibrancy = 0.1696
		},
	},
})

-- https://wiki.hypr.land/Configuring/Variables/#animations
hl.config({
	animations = {
		enabled = false,
	},
})

-- Default animations, see https://wiki.hypr.land/Configuring/Animations/ for more
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
-- hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 0.5} } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 6, bezier = "default", style = "slidefadevert -100%" })
-- hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 6, bezier = "default", style = "slidefadevert 100%" })

-- hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
-- hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
-- hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
-- hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
-- hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- hl.animation({ leaf = "global",    enabled = true,  speed = 10,   bezier = "default" })
-- hl.animation({ leaf = "border",    enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windows",   enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windowsIn", enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
-- hl.animation({ leaf = "windowsOut",enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
-- hl.animation({ leaf = "fadeIn",    enabled = true,  speed = 1.73, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeOut",   enabled = true,  speed = 1.46, bezier = "almostLinear" })
-- hl.animation({ leaf = "fade",      enabled = true,  speed = 3.03, bezier = "quick" })
-- hl.animation({ leaf = "layers",    enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "layersIn",  enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
-- hl.animation({ leaf = "layersOut", enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
-- hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
		smart_split = true,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

-- https://wiki.hypr.land/Configuring/Variables/#misc
hl.config({
	misc = {
		force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		-- disable_hyprland_logo = false -- If true disables the random hyprland logo / anime girl background. :(
	},
})

--------------
-- INPUT -----
--------------

-- https://wiki.hypr.land/Configuring/Variables/#input
hl.config({
	input = {
		kb_layout = "at",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		numlock_by_default = true,

		follow_mouse = 1,

		touchpad = {
			natural_scroll = true,
			disable_while_typing = false,
		},

		-- sensitivity = -0.5 -- -1.0 - 1.0, 0 means no modification.
	},
})

-- https://wiki.hypr.land/Configuring/Variables/#gestures
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace", enabled = true })

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
-- hl.gesture({ fingers = 3, direction = "right", action = "workspace", workspace = "e+1" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
local touchpadEnabled = false -- $TOUCHPAD_ENABLED
hl.device({
	name = "asuf1204:00-2808:0202-touchpad",
	enabled = touchpadEnabled,
	sensitivity = 0,
})

hl.device({
	name = "logitech-mx-master-1",
	enabled = true,
	sensitivity = -0.7,
})

-------------------
-- KEYBINDINGS ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for more
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("shutdown now"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("reboot"))
hl.bind("CTRL + ALT + PAUSE", hl.dsp.exit())
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("pkill wofi || " .. menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(clipboardHistory))
hl.bind(mainMod .. " + D", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + S", hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Move focus with mainMod + arrow keys or with mainMod + vim keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspaces
hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + T", hl.dsp.workspace.toggle_special("terminal"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.move({ workspace = "special:terminal" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Go through existing workspaces with mainMod + arrow keys or with MainMod + tab/up
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind(mainMod .. " + dead_circumflex", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("CTRL + ALT + right", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("CTRL + ALT + left", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("CTRL + ALT + L", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("CTRL + ALT + H", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })

-- Moving windows around, both with arrow keys and with vim key bindings
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }), { repeating = true })

local resizeSize = 100 -- $resizeSize
-- NOTE: the original used `%resizeSize` (= 100% of the window's current size)
--       for `right`/`L`; the Lua window.resize API takes pixel numbers only (no
--       "%" percentages), so it is mapped to the numeric value 100 here.
-- resize with arrow keys
hl.bind(
	mainMod .. " + CTRL + right",
	hl.dsp.window.resize({ x = resizeSize, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + left",
	hl.dsp.window.resize({ x = -resizeSize, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + up",
	hl.dsp.window.resize({ x = 0, y = -resizeSize, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + down",
	hl.dsp.window.resize({ x = 0, y = resizeSize, relative = true }),
	{ repeating = true }
)
-- resize with hjkl
hl.bind(
	mainMod .. " + CTRL + L",
	hl.dsp.window.resize({ x = resizeSize, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + H",
	hl.dsp.window.resize({ x = -resizeSize, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + K",
	hl.dsp.window.resize({ x = 0, y = -resizeSize, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + J",
	hl.dsp.window.resize({ x = 0, y = resizeSize, relative = true }),
	{ repeating = true }
)

local moveSize = 100 -- $moveSize
-- moving the floating window with the arrow keys
hl.bind(
	mainMod .. " + SHIFT + right",
	hl.dsp.window.move({ x = moveSize, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + left",
	hl.dsp.window.move({ x = -moveSize, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ x = 0, y = -moveSize, relative = true }), { repeating = true })
hl.bind(
	mainMod .. " + SHIFT + down",
	hl.dsp.window.move({ x = 0, y = moveSize, relative = true }),
	{ repeating = true }
)
-- moving the floating window with hjkl
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ x = moveSize, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ x = -moveSize, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ x = 0, y = -moveSize, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ x = 0, y = moveSize, relative = true }), { repeating = true })

-- Shortcut to open a mini calculator window
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("galculator"), { repeating = true })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(controlCenter), { repeating = true })

-- Disable / enable the screen
hl.bind(mainMod .. " + F1", function()
	hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor = "eDP-1" }))
	hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor = "eDP-2" }))
end)
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("~/.local/bin/toggle_screen"), { locked = true })

-- Win + F7 / F8 for brightness control when in AsusMuxDgpu mode (the screen is connected to the integrated graphics, the shortcuts dont work in dgpu mode)
hl.bind(mainMod .. " + F7", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F8", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })

-- Laptop multimedia keys for audio and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(noctalia .. " ipc call media next"), { locked = true, repeating = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctalia .. " ipc call media pause"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(noctalia .. " ipc call media play"), { locked = true, repeating = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(noctalia .. " ipc call media previous"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd(noctalia .. " ipc call media playPause"),
	{ locked = true, repeating = true }
)

-- Misc control of the keys
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("~/.local/bin/toggle_touchpad"), { locked = true })

-- Take a screenshot of an area and save the screenshot
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("cd ~/Bilder/Screenshots/; grim -g \"$(slurp)\"; cd ~"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Bilder/Screenshots/"))

-- SUBMAPS
-- Submap to displac all pressed keys, enterd / and exited with MOD + D, terminal program to tell which keys are pressed: "wev"
-- hl.bind(mainMod .. " + O", hl.dsp.submap("displayKeyPress"))
-- hl.define_submap("displayKeyPress", function()
--     hl.bind("catchall", hl.dsp.exec_cmd('hyprctl notify -1 1000 "rgb(E1B964)" "Key pressed"'))
--     hl.bind(mainMod .. " + O", hl.dsp.submap("reset"))
-- end)
-- hl.define_submap("reset", function() end)

-- Will switch to a custom submap from which all kinds of commands, such as resarting waybar, can be accessed without cluttering the "main" shortcuts
-- Is similar to the vim ex mode, uses then : to enter it but instead of : it uses mainMod + dot)
-- hl.bind(mainMod .. " + period", hl.dsp.submap("commands"))
-- hl.define_submap("commands", function()
--     hl.bind("dead_acute",          hl.dsp.exec_cmd("pkill waybar; waybar"),          { repeating = true })
--     hl.bind("SHIFT + dead_acute",  hl.dsp.exec_cmd("pkill hyprlauncher; hyprlauncher -d"), { repeating = true })
--     hl.bind("F",                   hl.dsp.exec_cmd("XDG_MENU_PREFIX=arch- kbuildsycoca6"), { repeating = true })
-- end)
-- Shortcut to toggle hyprpicker (copies a color)
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("hyprpicker -a"), { repeating = true })
-- hl.bind(mainMod .. " + period", hl.dsp.submap("reset"))
-- hl.define_submap("reset", function() end)

-------------------------------
-- WINDOWS AND WORKSPACES -----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

-- Example windowrule v1
-- hl.window_rule({ match = { class = "(kitty)" }, float = true })

-- Ignore maximize requests from all apps. You'll probably like this.
-- windowrulev2 = suppressevent maximize, class:.* -- Old
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- Fix some dragging issues with XWayland
-- windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0 -- Old
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Stuff for screen sharing
-- windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
-- windowrulev2 = noanim,class:^(xwaylandvideobridge)$
-- windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$
-- windowrulev2 = maxsize 1 1,class:^(xwaylandvideobridge)$
-- windowrulev2 = noblur,class:^(xwaylandvideobridge)$
hl.window_rule({
	name = "screenshare-xwaylandvideobridge",
	match = { class = "^(xwaylandvideobridge)$" },

	opacity = "0.0 override",
	no_anim = true,
	no_initial_focus = true,
	max_size = "1 1",
	no_blur = true,
})

-- Make apps tile by default
-- windowrulev2 = tile,initialTitle:^(ONLYOFFICE Desktop Editors)$
hl.window_rule({
	name = "tile-onlyoffice",
	match = { initial_title = "^(ONLYOFFICE Desktop Editors)$" },
	tile = true,
})
-- windowrulev2 = tile,initialTitle:^(Godot)$
hl.window_rule({
	name = "tile-godot",
	match = { initial_title = "^(Godot)$" },
	tile = true,
})
-- windowrulev2 = tile,class:^(lite-xl)$
hl.window_rule({
	name = "tile-lite-xl",
	match = { class = "^(lite-xl)$" },
	tile = true,
})

-- Make apps float by default
-- windowrulev2 = float,initialTitle:^(galculator)$
hl.window_rule({
	name = "float-galculator",
	match = { initial_title = "^(galculator)$" },
	float = true,
})
-- windowrulev2 = float,initialTitle:^(org.kde.kdialog)$
hl.window_rule({
	name = "float-kdialog",
	match = { initial_title = "^(org.kde.kdialog)$" },
	float = true,
})

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "w[2-100]", gaps_out = 2, gaps_in = 1 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

-- Calculator window rules
-- hl.window_rule({ match = { class = "(galculator)", title = "(galculator)" }, float = true, size = { width_ratio = 0.1, height_ratio = 0.2 } })
