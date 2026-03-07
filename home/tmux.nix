{ pkgs, ... }:
let
  # https://github.com/gpakosz/.tmux (fetched 2025-03-08)
  gpakoszTmux = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "af33f07134b76134acca9d01eacbdecca9c9cda6";
    hash = "sha256-nXm664l84YSwZeRM4Hsweqgz+OlpyfwXcgEdyNGhaGA=";
  };
in
{
  home.packages = [ pkgs.tmux ];

  home.file.".tmux.conf".source = "${gpakoszTmux}/.tmux.conf";
  home.file.".tmux.conf.local".source = ./dotfiles/tmux/tmux.conf.local;
}
