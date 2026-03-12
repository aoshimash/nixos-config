{ lib, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;

  # Prevent blueman-applet from auto-starting; the Waybar bluetooth module
  # provides the tray icon with rofi-bluetooth / blueman-manager on click.
  systemd.user.services.blueman-applet.wantedBy = lib.mkForce [ ];
}
