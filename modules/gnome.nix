{ ... }:
{
  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true; # Explicit for NVIDIA
  services.xserver.desktopManager.gnome.enable = true;
}
