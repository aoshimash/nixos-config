{ ... }:
{
  imports = [
    ./browsers.nix
    ./hyprland.nix
    ./fcitx5.nix
    ./wofi.nix
  ];
  home.username = "aoshima";
  home.homeDirectory = "/home/aoshima";
  home.stateVersion = "25.05";

  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    userName = "Shuji Aoshima";
    userEmail = "47586723+aoshimash@users.noreply.github.com";
  };
}
