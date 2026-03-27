{ pkgs, ... }:
{
  home.packages = [
    pkgs.pavucontrol
    pkgs.rofi-bluetooth
  ];

  catppuccin.waybar.enable = true;

  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "HackGen35 Console NF", monospace;
        font-size: 13px;
        min-height: 0;
      }

      #workspaces button {
        padding: 0 10px;
        min-width: 24px;
        margin: 4px 2px;
        border-radius: 4px;
        border: none;
      }

      #workspaces button.visible {
        border-bottom: 2px solid @surface1;
      }

      #workspaces button.active {
        border-bottom: 2px solid @mauve;
      }

      #clock,
      #network,
      #pulseaudio,
      #bluetooth,
      #tray,
      #custom-power {
        padding: 0 10px;
      }

      #bluetooth {
        font-size: 18px;
      }

      #pulseaudio-slider {
        min-width: 120px;
        padding: 0 5px;
      }

      #pulseaudio-slider trough {
        min-height: 8px;
        border-radius: 4px;
      }

      #pulseaudio-slider highlight {
        min-height: 8px;
        border-radius: 4px;
      }

      #custom-power {
        color: @red;
      }

      #custom-power:hover {
        color: @text;
        background: alpha(@red, 0.25);
        border-radius: 4px;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "group/audio"
          "bluetooth"
          "tray"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{windows}";
          format-window-separator = " ";
          window-rewrite-default = "󰏗";
          window-rewrite = {
            "com.mitchellh.ghostty" = "󰆍";
            "firefox" = "󰈹";
            "google-chrome" = "󰊯";
            "chromium" = "󰊯";
            "code" = "󰨞";
            "Bitwarden" = "󰌋";
            "Freelens" = "󰠳";
            "discord" = "󰙯";
            "slack" = "󰒱";
            "nautilus" = "󰉋";
            "thunar" = "󰉋";
            "spotify" = "󰓇";
            "obsidian" = "󱓧";
          };
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "{:%A, %B %d, %Y}";
        };

        network = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid}\n{ifname}: {ipaddr}/{cidr}\nSignal: {signalStrength}%";
        };

        "group/audio" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 300;
            transition-left-to-right = false;
          };
          modules = [
            "pulseaudio"
            "pulseaudio/slider"
          ];
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  Muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
          on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        };

        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };

        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱";
          format-disabled = "󰂲";
          on-click = "rofi-bluetooth";
          on-click-right = "blueman-manager";
          tooltip-format = "{controller_alias}\n{num_connections} connected\n{device_enumerate}";
          tooltip-format-enumerate-connected = "- {device_alias}";
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };

        "custom/power" = {
          format = "󰐥";
          tooltip = false;
          on-click = "wlogout";
        };
      };
    };
  };
}
