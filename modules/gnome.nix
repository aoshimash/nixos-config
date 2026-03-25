{ pkgs, ... }:
{
  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true; # Explicit for NVIDIA
  services.desktopManager.gnome.enable = true;

  # IBus Mozc (Google Japanese Input equivalent)
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc ];
  };
}
