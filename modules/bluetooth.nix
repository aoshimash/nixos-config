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

  # Prevent blueman-applet from auto-starting; GNOME's AppIndicator extension
  # and built-in Bluetooth settings handle Bluetooth UI.
  systemd.user.services.blueman-applet.wantedBy = lib.mkForce [ ];
}
