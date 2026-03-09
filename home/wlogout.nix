{ ... }:
{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "󰌾  Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit";
        text = "󰍃  Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "󰤄  Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "󰜉  Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "󰐥  Shutdown";
        keybind = "s";
      }
    ];

    style = ''
      * {
        background-image: none;
        font-family: "HackGen35 Console NF", monospace;
        font-size: 16px;
      }

      window {
        background-color: rgba(30, 30, 46, 0.85);
      }

      button {
        color: #cdd6f4;
        background-color: #313244;
        border: none;
        border-radius: 12px;
        margin: 10px;
      }

      button:hover {
        background-color: #45475a;
      }

      button:focus {
        background-color: #45475a;
        outline: 2px solid #89b4fa;
      }

      #lock {
        background-color: rgba(137, 180, 250, 0.15);
      }
      #lock:hover {
        background-color: rgba(137, 180, 250, 0.3);
      }

      #logout {
        background-color: rgba(166, 227, 161, 0.15);
      }
      #logout:hover {
        background-color: rgba(166, 227, 161, 0.3);
      }

      #suspend {
        background-color: rgba(249, 226, 175, 0.15);
      }
      #suspend:hover {
        background-color: rgba(249, 226, 175, 0.3);
      }

      #reboot {
        background-color: rgba(250, 179, 135, 0.15);
      }
      #reboot:hover {
        background-color: rgba(250, 179, 135, 0.3);
      }

      #shutdown {
        background-color: rgba(243, 139, 168, 0.15);
      }
      #shutdown:hover {
        background-color: rgba(243, 139, 168, 0.3);
      }
    '';
  };
}
