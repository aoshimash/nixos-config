{ ... }:
{
  # OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Authorized SSH public key for aoshima user
  users.users.aoshima.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9iPL1hhRYMCQ8Ypz8PkzGL/Ruh+0CPcCHVWtuGyhS aoshima@MacBookPro.local"
  ];

  # Allow SSH only from local network
  networking.firewall = {
    extraCommands = ''
      iptables -I nixos-fw 1 -p tcp --dport 22 -s 192.168.0.0/24 -j nixos-fw-accept
      iptables -I nixos-fw 2 -p tcp --dport 22 -j nixos-fw-log-refuse
    '';
    extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 22 -s 192.168.0.0/24 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 22 -j nixos-fw-log-refuse || true
    '';
  };
}
