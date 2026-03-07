{ pkgs, ... }:
{
  programs.firefox.enable = true;

  home.packages = [
    pkgs.google-chrome
  ];
}
