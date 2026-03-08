{ pkgs, ... }:
{
  home.packages = [
    pkgs.code-cursor
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  programs.emacs.enable = true;
}
