{
  config,
  lib,
  pkgs,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/ndots/modules/home-manager/hyprland/hypr";
in
{
  options.custom.hyprland.enable = lib.mkEnableOption "Hyprland user config";

  config = lib.mkIf config.custom.hyprland.enable {

    systemd.user.targets.hyprland-session = {
      Unit = {
        Description = "hyprland compositor session";
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
    wayland.windowManager.hyprland.settings.input.numlock_by_default = true;

    # Use theme seed directly instead of .active symlink
    # The .active symlink is created during activation, but we need
    # the file to exist during the build phase
    xdg.configFile."hypr/colors.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ndots/modules/home-manager/theme/seeds/gruvbox-dark/hypr/colors.lua";

    xdg.configFile."hypr/hyprland.lua".text = ''
            local home = os.getenv("HOME")
            local config_dir = home .. "/.config/hypr"
            package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

            -- Pull in themed border colors. Lives outside the Nix store.
            dofile(home .. "/.config/hypr/colors.lua")

            -- Monitors ----------------------------------------
            hl.monitor({
            	output = "DP-1",
            	mode = "1920x1080@239.96Hz",
            	position = "1080x0",
            	scale = 1,
            })

            -- Looks ----------------------------------------
            hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice-Right")
            hl.env("HYPRCURSOR_SIZE", "24")

            hl.config({
            	input = {
            		kb_layout = "us,us",
            		kb_variant = ",intl",
            		kb_options = "grp:alt_shift_toggle",
            	},
            	general = {
            		gaps_in = 7,
            		gaps_out = 10,
            		border_size = 2,
            		layout = "dwindle",
            	},
            	scrolling = {
            		fullscreen_on_one_column = true,
            		column_width = 0.95,
            		focus_fit_method = 0,
            	},
            	dwindle = {
            		preserve_split = true,
            	},
            	master = {
            		new_status = "slave",
            		allow_small_split = false,
            		special_scale_factor = 0.75,
            		mfact = 0.40,
            		orientation = "center",
            		new_on_top = true,
            	},
            })

            hl.device({
            	name = "8bitdo-retro-18-numpad-keyboard",
            	kb_options = "numpad:mac",
            	numlock_by_default = true,
            })

            hl.config({
            	decoration = {
            		rounding = 15,
            		rounding_power = 2,
            		active_opacity = 1.0,
            		inactive_opacity = 0.75,
            		fullscreen_opacity = 1.0,
            		blur = {
            			enabled = true,
            			size = 1,
            			passes = 2,
            			new_optimizations = true,
            			vibrancy = 0.5,
            			vibrancy_darkness = 0.2,
            		},
            		shadow = {
            			enabled = true,
            			range = 15,
            			render_power = 3,
            			color = "rgba(121212aa)",
            		},
            	},
            })

            hl.layer_rule({
            	name = "swaync-control-center-blur",
            	match = { namespace = "swaync-control-center" },
            	blur = true,
            	dim_around = true,
            	ignore_alpha = 0.5,
            	no_screen_share = true,
            })
            hl.layer_rule({
            	name = "swaync-notification-blur",
            	match = { namespace = "swaync-notification-window" },
            	blur = true,
            	ignore_alpha = 0.5,
            	no_screen_share = true,
            })

            -- Animations ----------------------------------------
            hl.config({ animations = { enabled = true } })

            -- Bezier curves
            hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
            hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
            hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
            hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
            hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

            -- Animations
            hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
            hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
            hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
            hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 95%" })
            hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 95%" })
            hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
            hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
            hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
            hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
            hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
            hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
            hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
            hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
            hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slidefade 10%" })
            hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slidefade 10%" })
            hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slidefade 10%" })

            -- Autostart ----------------------------------------
            hl.on("hyprland.start", function()
            	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
            	hl.exec_cmd("systemctl --user start hyprland-session.target")
            	hl.exec_cmd("waybar")
            	hl.exec_cmd("systemctl --user enable --now power-profile-hypridle.service")
            	hl.exec_cmd("swaync")
      	      hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice-Right 24")
            end)

            -- Programs ----------------------------------------
            local p = {
            	terminal = "alacritty",
            	file_manager = "thunar",
            	menu = "pkill rofi || " .. home .. "/.config/rofi/launchers/type-7/launcher.sh",
            	logout_menu = "wlogout -b 5 -T 400 -B 400",
            	toggle_notifications = "swaync-client -t -sw",
            	screen_ocr = home .. "/.local/bin/read-screen",
            }

            -- Binds ----------------------------------------
            local mod = "SUPER"
            local mod_shft = "SUPER + SHIFT"
            local mod_ctrl = "SUPER + CTRL"
            local mod_alt = "SUPER + ALT"

            -- ---------- App launchers / global actions ----------
            hl.bind(mod .. " + Return", hl.dsp.exec_cmd(p.terminal))
            hl.bind(mod .. " + Q", hl.dsp.window.close())
            hl.bind(mod_shft .. " + Q", hl.dsp.exec_cmd("killall zoom"))
            hl.bind(mod .. " + E", hl.dsp.exec_cmd(p.file_manager))
            hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
            hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
            hl.bind(mod .. " + M", hl.dsp.layout("togglesplit")) -- dwindle
            hl.bind(mod .. " + N", hl.dsp.exec_cmd(p.toggle_notifications))
            hl.bind(mod .. " + Space", hl.dsp.exec_cmd(p.menu))
            hl.bind(mod .. " + T", hl.dsp.exec_cmd("theme-picker"))
            hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd(p.logout_menu))

            -- ---------- Focus movement (vim) ----------
            hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
            hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
            hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
            hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

            -- ---------- Move window ----------
            hl.bind(mod_shft .. " + H", hl.dsp.window.move({ direction = "left" }))
            hl.bind(mod_shft .. " + L", hl.dsp.window.move({ direction = "right" }))
            hl.bind(mod_shft .. " + K", hl.dsp.window.move({ direction = "up" }))
            hl.bind(mod_shft .. " + J", hl.dsp.window.move({ direction = "down" }))

            -- ---------- Splitratio (dwindle layoutmsg) ----------
            hl.bind(mod .. " + comma", hl.dsp.layout("splitratio -0.1"))
            hl.bind(mod .. " + period", hl.dsp.layout("splitratio 0.1"))

            -- ---------- Workspaces (Y U I O P -> 1..5) ----------
            local ws_keys = { Y = 1, U = 2, I = 3, O = 4, P = 5 }
            for key, ws in pairs(ws_keys) do
            	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
            	hl.bind(mod_shft .. " + " .. key, hl.dsp.window.move({ workspace = ws }))
            end

            -- ---------- Special workspace (scratchpad) ----------
            hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
            hl.bind(mod_shft .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

            -- ---------- Workspace scroll ----------
            hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
            hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

            -- ---------- Mouse drag/resize ----------
            hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
            hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

            -- ---------- Multimedia (locked + repeating) ----------
            local el = { locked = true, repeating = true }
            hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), el)
            hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), el)
            hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), el)
            hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), el)
            hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), el)
            hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), el)

            -- ---------- Media (locked, no repeat) ----------
            local l = { locked = true }
            hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), l)
            hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), l)
            hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), l)
            hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), l)

            -- ---------- Screenshots ----------
            hl.bind(mod_shft .. " + 2", hl.dsp.exec_cmd("hyprshot -m output -m DP-1 -o ~/Pictures/Screenshots"))
            hl.bind(mod_shft .. " + 3", hl.dsp.exec_cmd("hyprshot -m window -m active -o ~/Pictures/Screenshots"))
            hl.bind(mod_shft .. " + 4", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))

            -- ---------- OBS Recording ----------
            hl.bind(mod_shft .. " + 9", hl.dsp.exec_cmd("obs-cmd recording toggle"))
            hl.bind(mod .. " + 9", hl.dsp.exec_cmd("obs-cmd recording toggle-pause"))

            -- Disable animations on the screenshot selection layer
            hl.layer_rule({
            	name = "no-anim-selection",
            	match = { namespace = "selection" },
            	no_anim = true,
            })

            hl.bind(mod_shft .. " + 0", hl.dsp.exec_cmd(p.screen_ocr))

            -- ---------- Lock / suspend ----------
            hl.bind(mod_alt .. " + L", hl.dsp.exec_cmd("hyprlock"))
            hl.bind(mod .. " + ALT + CTRL + L", hl.dsp.exec_cmd("systemctl suspend"))

            -- ---------- Power profile cycling ----------
            hl.bind(mod .. " + bracketright", hl.dsp.exec_cmd("power-profile next"))
            hl.bind(mod .. " + bracketleft", hl.dsp.exec_cmd("power-profile prev"))

            -- ---------- Waybar reload ----------
            hl.bind(mod_alt .. " + R", hl.dsp.exec_cmd("/home/jpporta/.config/waybar/scripts/launch.sh"))

            -- ---------- Dictation ----------
            hl.bind(mod .. " + code:71", hl.dsp.exec_cmd("dictate-toggle"))
            hl.bind(mod .. " + code:72", hl.dsp.exec_cmd("dictate-history"))
            hl.bind(mod_shft .. " + code:71", hl.dsp.exec_cmd("dictate-toggle -c"))
            -- ---------- misc ----------
            hl.config({
            	misc = {
            		force_default_wallpaper = 0,
            		disable_hyprland_logo = true,
            	},
            })

            -- ---------- window rules ----------
            -- Zoom Behave -----------
            hl.window_rule({
              match = { class = "^zoom$", title = "^annotate_toolbar$" },
              float = true,
            })
            hl.window_rule({
              match = { class = "^zoom$" },
              no_blur = true,
              border_size = 0,
              no_initial_focus = true,
              no_shadow = true,
            })

            -- Ignore maximize requests from apps.
            hl.window_rule({
            	name = "Ignore Maximize Requests",
            	match = { class = ".*" },
            	suppress_event = "maximize",
            })

            -- Fix some dragging issues with XWayland.
            hl.window_rule({
            	name = "XWayland Drag Fix",
            	match = {
            		xwayland = 1,
            		title = "^$",
            		class = "^$",
            		float = true,
            		fullscreen = false,
            		pin = false,
            	},
            	no_focus = true,
            })

            hl.window_rule({
                    name = "Pinentry Center",
                    match = { class = "^(pinentry-.*)$" },
                    float = true,
                    center = true,
                    stay_focused = true,
            })

            -- Picture-in-Picture: pinned floating mini-player in bottom-right quadrant.
            hl.window_rule({
            	name = "PIP",
            	match = { title = "Picture-in-Picture" },
            	pin = 1,
            	float = 1,
            	size = "(monitor_w/4) (monitor_h/4)",
            	move = "(3*monitor_w/4)-22 (monitor_h-window_h-22)",
            })

            -- Firefox PiP: no transparency/blur
            hl.window_rule({
            	name = "Firefox PiP no blur",
            	match = { title = "Picture-in-Picture" },
            	no_blur = true,
              opacity = "1 override",
            })

            hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
    '';
  };
}
