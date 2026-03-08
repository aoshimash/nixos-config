{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.google-drive-ocamlfuse ];
}
