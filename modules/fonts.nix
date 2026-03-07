{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      hackgen-nf-font
    ];

    fontconfig.defaultFonts = {
      sansSerif = [
        "Noto Sans CJK JP"
        "Noto Color Emoji"
      ];
      serif = [
        "Noto Serif CJK JP"
        "Noto Color Emoji"
      ];
      monospace = [
        "HackGen35 Console NF"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
