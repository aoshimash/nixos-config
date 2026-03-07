{ pkgs, ... }:
let
  aqua = pkgs.callPackage ../pkgs/aqua.nix { };
  freelens = pkgs.callPackage ../pkgs/freelens.nix { };
in
{
  imports = [
    ./browsers.nix
    ./hyprland.nix
    ./fcitx5.nix
    ./wofi.nix
    ./waybar.nix
    ./editors.nix
    ./mako.nix
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
    go
    gopls
    playwright-driver.browsers

    # Python
    uv
    ruff

    # Kubernetes
    kubectl
    k9s
    freelens

    # Containers
    ctop

    # AI CLI
    codex
    gemini-cli

    # Shell productivity
    fzf
    bat
    eza
    zoxide
    direnv
    lazygit
    delta

    # System info
    dust
    duf

    # Utilities
    yq
    rsync
    aqua
  ];

  home.file.".claude/CLAUDE.md".source = ./dotfiles/claude/CLAUDE.md;

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };

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
