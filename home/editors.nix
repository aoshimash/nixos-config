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

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.xclip ];
  };

  home.file.".emacs.d/init.el".text = ''
    (xclip-mode 1)
  '';
}
