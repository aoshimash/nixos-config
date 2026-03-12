{ pkgs, ... }:
{
  home.packages = [
    pkgs.pavucontrol
    pkgs.rofi-bluetooth
  ];

  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "HackGen35 Console NF", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 10px;
        min-width: 24px;
        color: #a6adc8;
        background: rgba(69, 71, 90, 0.5);
        margin: 4px 2px;
        border-radius: 4px;
        border: none;
      }

      #workspaces button.visible {
        color: #cdd6f4;
        border-bottom: 2px solid #585b70;
      }

      #workspaces button.active {
        color: #cdd6f4;
        background: rgba(137, 180, 250, 0.25);
        border-bottom: 2px solid #89b4fa;
      }

      #clock,
      #network,
      #pulseaudio,
      #bluetooth,
      #tray,
      #custom-power {
        padding: 0 10px;
      }

      #pulseaudio-slider {
        min-width: 120px;
        padding: 0 5px;
      }

      #pulseaudio-slider trough {
        min-height: 8px;
        border-radius: 4px;
        background-color: rgba(69, 71, 90, 0.5);
      }

      #pulseaudio-slider highlight {
        min-height: 8px;
        border-radius: 4px;
        background-color: #89b4fa;
      }

      #custom-power {
        color: #f38ba8;
      }

      #custom-power:hover {
        color: #cdd6f4;
        background: rgba(243, 139, 168, 0.25);
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
