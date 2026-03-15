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
        background-color: rgba(40, 42, 54, 0.85);
      }

      button {
        color: #f8f8f2;
        background-color: #44475a;
        border: none;
        border-radius: 12px;
        margin: 10px;
      }

      button:hover {
        background-color: #6272a4;
      }

      button:focus {
        background-color: #6272a4;
        outline: 2px solid #bd93f9;
      }

      #lock {
        background-color: rgba(139, 233, 253, 0.15);
      }
      #lock:hover {
        background-color: rgba(139, 233, 253, 0.3);
      }

      #logout {
        background-color: rgba(80, 250, 123, 0.15);
      }
      #logout:hover {
        background-color: rgba(80, 250, 123, 0.3);
      }

      #suspend {
        background-color: rgba(241, 250, 140, 0.15);
      }
      #suspend:hover {
        background-color: rgba(241, 250, 140, 0.3);
      }

      #reboot {
        background-color: rgba(255, 184, 108, 0.15);
      }
      #reboot:hover {
        background-color: rgba(255, 184, 108, 0.3);
      }

      #shutdown {
        background-color: rgba(255, 85, 85, 0.15);
      }
      #shutdown:hover {
        background-color: rgba(255, 85, 85, 0.3);
      }
    '';
  };
}
