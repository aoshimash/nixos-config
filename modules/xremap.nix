{ ... }:
{
  services.xremap = {
    enable = true;
    withHypr = true;
    serviceMode = "user";
    userName = "aoshima";
    # xremap operates at the evdev level (keycodes), but Hyprland applies the
    # Dvorak layout AFTER xremap's output. Output keycodes must be reverse-mapped
    # through Dvorak so the application receives the correct keysyms:
    #   KEY_I   → Dvorak → keysym 'c'
    #   KEY_DOT → Dvorak → keysym 'v'
    config.keymap = [
      {
        name = "Terminal: Super+C/V to Ctrl+Shift+C/V";
        application.only = [ "com.mitchellh.ghostty" ];
        remap = {
          "Super-c" = "C-Shift-i";
          "Super-v" = "C-Shift-dot";
        };
      }
      {
        name = "GUI: Super+C/V to Ctrl+C/V";
        application.not = [ "com.mitchellh.ghostty" ];
        remap = {
          "Super-c" = "C-i";
          "Super-v" = "C-dot";
        };
      }
    ];
  };
}
