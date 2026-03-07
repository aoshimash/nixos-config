{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  programs.emacs.enable = true;
}
