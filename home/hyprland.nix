{ pkgs, ... }:
let
  closeAllWindows = pkgs.writeShellScript "hypr-close-all-windows" ''
    ws=$(hyprctl activeworkspace -j | jq '.id')
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $ws) | .address" \
      | xargs -I{} hyprctl dispatch closewindow address:{}
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      # Monitor layout (left to right): JAPANNEXT 2K → DELL 2K → LG 4K
      monitor = [
        "DP-6, 2560x1440@144, 0x0, 1" # JAPANNEXT (left)
        "DP-9, 2560x1440@144, 2560x0, 1" # DELL G3223D (center)
        "DP-8, 3840x2160@60, 5120x0, 1.5" # LG HDR 4K (right)
      ];

      # Workspace-to-monitor assignment (round-robin: left → center → right)
      workspace = [
        "1, monitor:DP-6, default:true"
        "2, monitor:DP-9, default:true"
        "3, monitor:DP-8, default:true"
        "4, monitor:DP-6"
        "5, monitor:DP-9"
        "6, monitor:DP-8"
        "7, monitor:DP-6"
        "8, monitor:DP-9"
        "9, monitor:DP-8"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
        natural_scroll = true;
      };

      exec-once = [
        "fcitx5 -d"
        "waybar"
        "blueman-applet"
      ];

      decoration.blur = {
        enabled = true;
        size = 5;
        passes = 2;
      };

      layerrule = [
        "blur on, match:namespace waybar"
      ];

      "$mod" = "SUPER";
      "$terminal" = "ghostty";

      bindl = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        "$mod, D, exec, wofi --show drun"
        "$mod, Return, exec, $terminal"
        "$mod, W, killactive"
        "$mod, M, exit"
        "$mod, T, togglefloating"
        "$mod, F, fullscreen"

        # Move focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Focus monitor
        "$mod, 1, focusmonitor, DP-6" # left
        "$mod, 2, focusmonitor, DP-9" # center
        "$mod, 3, focusmonitor, DP-8" # right

        # Move window to monitor
        "$mod SHIFT, 1, movewindow, mon:DP-6" # left
        "$mod SHIFT, 2, movewindow, mon:DP-9" # center
        "$mod SHIFT, 3, movewindow, mon:DP-8" # right

        # Cycle windows on active workspace
        "$mod, Tab, cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"

        # Cycle workspaces on active monitor
        "CTRL, Right, workspace, m+1"
        "CTRL, Left, workspace, m-1"
        ", mouse:276, workspace, m+1" # MX Ergo forward button
        ", mouse:275, workspace, m-1" # MX Ergo back button

        # Delete workspace (close all windows)
        "$mod SHIFT, W, exec, ${closeAllWindows}"

        # Add empty workspace on current monitor
        "$mod SHIFT, N, workspace, emptym"
      ];
    };
  };

  # Screen lock
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          outer_color = "rgb(137, 180, 250)";
          inner_color = "rgb(30, 30, 46)";
          font_color = "rgb(205, 214, 244)";
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
        }
      ];
    };
  };

  # Terminal emulator
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "HackGen35 Console NF";
      font-size = 12;
    };
  };
}
