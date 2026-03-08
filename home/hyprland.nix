{ ... }:
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

      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
      };

      exec-once = [
        "fcitx5 -d"
        "waybar"
        "blueman-applet"
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

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
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
