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

  # Prevent blueman from auto-starting via XDG autostart (system file: blueman.desktop);
  # the Waybar bluetooth module provides the icon with rofi-bluetooth on click.
  home-manager.sharedModules = [
    {
      xdg.configFile."autostart/blueman.desktop".text = ''
        [Desktop Entry]
        Hidden=true
      '';
    }
  ];
}
