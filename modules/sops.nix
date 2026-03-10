{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
}
