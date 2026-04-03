{ pkgs, ... }:
let
  closeAllWindows = pkgs.writeShellScript "hypr-close-all-windows" ''
    ws=$(hyprctl activeworkspace -j | jq '.id')
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $ws) | .address" \
      | xargs -I{} hyprctl dispatch closewindow address:{}
  '';

  workspaceNoWrap = pkgs.writeShellScript "hypr-workspace-no-wrap" ''
    direction=$1
    ws_json=$(hyprctl activeworkspace -j)
    current=$(echo "$ws_json" | jq '.id')
    monitor=$(echo "$ws_json" | jq -r '.monitor')

    case "$monitor" in
      DP-6) first=1; last=7 ;;
      DP-9) first=2; last=8 ;;
      DP-8) first=3; last=9 ;;
      *) exit 0 ;;
    esac

    if [ "$direction" = "next" ]; then
      [ "$current" -ne "$last" ] && hyprctl dispatch workspace "$((current + 3))"
    else
      [ "$current" -ne "$first" ] && hyprctl dispatch workspace "$((current - 3))"
    fi
  '';
in
{
  catppuccin.hyprland.enable = true;
  catppuccin.ghostty.enable = true;
  catppuccin.hyprlock.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    # TODO: Re-enable when hyprexpo is updated to match Hyprland 0.54.x in nixpkgs
    # plugins = [ pkgs.hyprlandPlugins.hyprexpo ];
    settings = {
      # Monitor layout (left to right): JAPANNEXT 2K → DELL 2K → LG 4K
      monitor = [
        "DP-6, 2560x1440@144, 0x0, 1" # JAPANNEXT (left)
        "DP-9, 2560x1440@144, 2560x0, 1" # DELL G3223D (center)
        "DP-8, 3840x2160@60, 5120x0, 1.75" # LG HDR 4K (right)
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

      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,20"
        "XMODIFIERS,@im=fcitx"
        "GTK_IM_MODULE,fcitx"
        "QT_IM_MODULE,fcitx"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
        natural_scroll = true;
      };

      exec-once = [
        "waybar"
        "wl-gammarelay-rs run"
        "wl-gammarelay-applet"
        "swww-daemon"
        "waypaper --restore"
      ];

      decoration.blur = {
        enabled = true;
        size = 5;
        passes = 2;
      };

      layerrule = [
        "blur on, match:namespace waybar"
      ];

      # TODO: Re-enable when hyprexpo is updated to match Hyprland 0.54.x in nixpkgs
      # plugin.hyprexpo = {
      #   columns = 3;
      #   gap_size = 5;
      #   workspace_method = "first m+0";
      # };

      windowrule = [
        {
          name = "overskride-popup";
          "match:class" = "^(io\\.github\\.kaii_lb\\.Overskride)$";
          float = "yes";
          size = "500 600";
        }
      ];

      "$mod" = "SUPER";
      "$terminal" = "ghostty";

      bindl = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightness up"
        ", XF86MonBrightnessDown, exec, brightness down"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        "$mod, Space, exec, rofi -show drun -show-icons"
        "$mod, P, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
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

        # TODO: Re-enable when hyprexpo is updated to match Hyprland 0.54.x in nixpkgs
        # "$mod, grave, hyprexpo:expo, toggle"

        # Cycle windows on active workspace
        "$mod, Tab, cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"

        # Cycle workspaces on active monitor (no wrap at boundaries)
        "CTRL, Right, exec, ${workspaceNoWrap} next"
        "CTRL, Left, exec, ${workspaceNoWrap} prev"
        ", mouse:276, exec, ${workspaceNoWrap} next" # MX Ergo forward button
        ", mouse:275, exec, ${workspaceNoWrap} prev" # MX Ergo back button

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
