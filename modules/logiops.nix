{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.logiops ];

  # logid systemd service
  systemd.services.logid = {
    description = "Logitech Configuration Daemon (logiops)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.logiops}/bin/logid -c /etc/logid.cfg";
      Restart = "on-failure";
    };
  };

  # Configuration file
  # TODO: Add button remapping for MX Ergo
  # See: https://github.com/PixlOne/logiops/wiki/Configuration
  environment.etc."logid.cfg".text = ''
    devices: (
      {
        name: "MX Ergo";
      }
    );
  '';
}
