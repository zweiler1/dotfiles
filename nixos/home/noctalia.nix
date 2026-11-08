{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;

    # Use the package from stable Nixpkgs.
    package = pkgs.noctalia;

    settings = {

      # -----------------------------------------------
      # BAR
      # -----------------------------------------------

      bar.default = {
        background_opacity = 0.85;
        center = [ "workspaces" ];

        end = [
          "tray"
          "group:g4"
          "group:g2"
          "group:g3"
          "control-center"
          "session"
        ];

        margin_ends = 0;
        padding = 10;
        radius = 0;
        show_on_workspace_switch = false;
        thickness = 26;

        start = [
          "launcher"
          "wallpaper"
          "clock"
          "media"
          "audio_visualizer"
          "group:g1"
          "group:g5"
        ];

        # Capsule groups.
        # TOML's [[bar.default.capsule_group]]
        # becomes a list of Nix attribute sets.

        capsule_group = [
          {
            id = "g1";
            members = [ "cpu" "temp" "ram" "sysmon" ];
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            opacity = 1.0;
            padding = 6.0;
          }

          {
            id = "g2";
            members = [ "network" "bluetooth" ];
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            opacity = 1.0;
            padding = 6.0;
          }

          {
            id = "g3";
            members = [ "volume" "brightness" "battery" ];
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            opacity = 1.0;
            padding = 6.0;
          }

          {
            id = "g4";
            members = [ "clipboard" "notifications" ];
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            opacity = 1.0;
            padding = 6.0;
          }

          {
            id = "g5";
            members = [ "network_rx" "network_tx" ];
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            opacity = 1.0;
            padding = 6.0;
          }
        ];
      };


      # -----------------------------------------------
      # BATTERY
      # -----------------------------------------------

      battery.device = {
        "/org/freedesktop/UPower/devices/battery_hidpp_battery_0" = {
          warning_threshold = 10;
        };
      };


      # -----------------------------------------------
      # DESKTOP WIDGETS
      # -----------------------------------------------

      desktop_widgets = {
        schema_version = 2;
        widget_order = [ ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
      };


      # -----------------------------------------------
      # LOCKSCREEN WIDGETS
      # -----------------------------------------------

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;

        widget_order = [
          "lockscreen-login-box@HDMI-A-1"
          "lockscreen-login-box@eDP-2"
          "lockscreen-login-box@FALLBACK"
        ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget = {
          "lockscreen-login-box@FALLBACK" = {
            box_height = 196.0;
            box_width = 810.0;
            cx = 960.0;
            cy = 898.0;
            output = "FALLBACK";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_password_reveal = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };

          "lockscreen-login-box@HDMI-A-1" = {
            box_height = 196.0;
            box_width = 810.0;
            cx = 800.0;
            cy = 718.0;
            output = "HDMI-A-1";
            placement_height = 900.0;
            placement_width = 1600.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_password_reveal = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };

          "lockscreen-login-box@eDP-2" = {
            box_height = 196.0;
            box_width = 810.0;
            cx = 640.0;
            cy = 618.0;
            output = "eDP-2";
            placement_height = 800.0;
            placement_width = 1280.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_password_reveal = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };
        };
      };


      # -----------------------------------------------
      # SHELL
      # -----------------------------------------------

      shell = {
        avatar_path =
          "${config.home.homeDirectory}/dotfiles/theme-manager/themes/active/Wallpaper/wallpaper_cutout.jpg";

        external_ip_enabled = true;
        screen_time_enabled = true;
      };


      # -----------------------------------------------
      # THEME
      # -----------------------------------------------

      theme = {
        source = "builtin";
        builtin = "Kanagawa";
        wallpaper_scheme = "soft";
      };


      # -----------------------------------------------
      # WALLPAPER
      # -----------------------------------------------

      wallpaper = {
        directory =
          "${config.home.homeDirectory}/dotfiles/theme-manager/themes/active/Wallpaper";

        default = {
          path =
            "${config.home.homeDirectory}/dotfiles/theme-manager/themes/active/Wallpaper/wallpaper.jpg";
        };
      };


      # -----------------------------------------------
      # WIDGETS
      # -----------------------------------------------

      widget = {

        audio_visualizer = {
          type = "audio_visualizer";
          mirrored = false;
          show_when_idle = true;
        };

        clock = {
          type = "clock";
          format = "%d. %b, %H:%M";
        };

        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
          show_value = false;
        };

        media = {
          type = "media";
          enabled = false;
        };

        network = {
          type = "network";
          show_label = false;
        };

        network_rx = {
          type = "sysmon";
          stat = "gpu_usage";
          show_value = false;
        };

        network_tx = {
          type = "sysmon";
          stat = "gpu_vram";
          show_value = false;
        };

        ram = {
          type = "sysmon";
          stat = "ram_used";
          show_value = false;
        };

        sysmon = {
          type = "sysmon";
          stat = "disk_free";
        };

        temp = {
          type = "sysmon";
          stat = "cpu_temp";
          show_value = false;
        };

        tray = {
          type = "tray";
          drawer = true;
        };

        wallpaper = {
          type = "wallpaper";
          enabled = false;
        };
      };
    };
  };
}
