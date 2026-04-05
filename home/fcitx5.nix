{ pkgs, ... }:
{
  systemd.user.services.fcitx5-daemon.Service = {
    Restart = "always";
    RestartSec = 3;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [ pkgs.fcitx5-mozc ];
      waylandFrontend = true;
      settings.inputMethod = {
        "Groups/0" = {
          Name = "デフォルト";
          "Default Layout" = "us";
          DefaultIM = "keyboard-us";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-us";
          Layout = "";
        };
        "Groups/0/Items/1" = {
          Name = "mozc";
          Layout = "";
        };
        GroupOrder."0" = "デフォルト";
      };
    };
  };
}
