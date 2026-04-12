{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc # libstdc++
    zlib # libz (compression, used by many Python native packages)
    libGL # libGL (OpenGL, used by cadquery-ocp / VTK)
    expat # libexpat (XML parsing, used by cadquery-ocp)
    libx11 # libX11 (X Window System, used by cadquery-ocp / VTK)
  ];
}
