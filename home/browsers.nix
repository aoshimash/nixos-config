{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    policies.Preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  home.packages = [
    (pkgs.google-chrome.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
      ];
    })
  ];
}
