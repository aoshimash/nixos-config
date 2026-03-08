{ ... }:
{
  services.xremap = {
    enable = true;
    withHypr = true;
    serviceMode = "user";
    userName = "aoshima";
    config.keymap = [
      {
        name = "Terminal: Super+C/V to Ctrl+Shift+C/V";
        application.only = [ "com.mitchellh.ghostty" ];
        remap = {
          "Super-c" = "C-Shift-c";
          "Super-v" = "C-Shift-v";
        };
      }
      {
        name = "GUI: Super+C/V to Ctrl+C/V";
        application.not = [ "com.mitchellh.ghostty" ];
        remap = {
          "Super-c" = "C-c";
          "Super-v" = "C-v";
        };
      }
    ];
  };
}
