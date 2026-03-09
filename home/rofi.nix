{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "ghostty";
    theme = ./dotfiles/rofi/nord.rasi;
  };
}
