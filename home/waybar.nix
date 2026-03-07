{ ... }:
{
  programs.waybar = {
    enable = true;
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
          format = "{id}";
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
