{ pkgs, ... }:
{
  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  # Login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };
}
