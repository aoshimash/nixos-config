{ pkgs, ... }:
{
  imports = [
    ./browsers.nix
    ./hyprland.nix
    ./fcitx5.nix
    ./wofi.nix
    ./waybar.nix
    ./editors.nix
  ];
  home.username = "aoshima";
  home.homeDirectory = "/home/aoshima";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # CLI tools
    curl
    unzip
    tree
    htop
    ripgrep
    fd
    jq
    file
    which

    # Development tools
    tmux
    llvmPackages.clang
    claude-code
  ];

  programs.zsh.enable = true;

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Shuji Aoshima";
    settings.user.email = "47586723+aoshimash@users.noreply.github.com";
  };
}
