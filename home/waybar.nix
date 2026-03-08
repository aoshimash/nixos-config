{ pkgs, ... }:
{
  home.packages = [ pkgs.pavucontrol ];

  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
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
      #tray {
        padding: 0 10px;
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
          "pulseaudio"
          "bluetooth"
          "tray"
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
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
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
        };

        bluetooth = {
          format = "󰂯 {status}";
          format-connected = "󰂱 {device_alias}";
          format-disabled = "󰂲";
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };
  };
}
