{ pkgs, ... }:
{
  home.packages = [
    pkgs.code-cursor
    pkgs.zed-editor
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

}
