{ pkgs, ... }:
{
  catppuccin.rofi.enable = true;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "ghostty";
  };
}
