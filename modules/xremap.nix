{ ... }:
{
  services.xremap = {
    enable = true;
    withHypr = true;
    serviceMode = "user";
    userName = "aoshima";
    # xremap operates at the evdev level (keycodes), but Hyprland applies the
    # Dvorak layout AFTER xremap's output. Both input and output keycodes must
    # use Dvorak physical positions (QWERTY keycode names):
    #   'c' = KEY_I, 'v' = KEY_DOT, 'z' = KEY_SLASH, 'a' = KEY_A, 'e' = KEY_D
    config.keymap = [
      {
        name = "Terminal: Mac-style shortcuts";
        application.only = [ "com.mitchellh.ghostty" ];
        remap = {
          "Super-i" = "C-Shift-i"; # Super+C → Ctrl+Shift+C (copy)
          "Super-dot" = "C-Shift-dot"; # Super+V → Ctrl+Shift+V (paste)
          "Super-slash" = "C-slash"; # Super+Z → Ctrl+Z (undo)
          "Super-a" = "C-a"; # Super+A → Ctrl+A (select all)
        };
      }
      {
        name = "GUI: Mac-style shortcuts and Emacs navigation";
        application.not = [ "com.mitchellh.ghostty" ];
        remap = {
          "Super-i" = "C-i"; # Super+C → Ctrl+C (copy)
          "Super-dot" = "C-dot"; # Super+V → Ctrl+V (paste)
          "Super-slash" = "C-slash"; # Super+Z → Ctrl+Z (undo)
          "Super-a" = "C-a"; # Super+A → Ctrl+A (select all)
          "C-a" = "Home"; # Ctrl+A → beginning of line
          "C-d" = "End"; # Ctrl+E → end of line
        };
      }
    ];
  };
}
