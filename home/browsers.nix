{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    policies.Preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
      "media.rdd-ffmpeg.enabled" = true;
      "widget.dmabuf.force-enabled" = true;
    };
  };

  home.packages = [
    (pkgs.google-chrome.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--disable-background-mode"
      ];
    })
    pkgs.vivaldi
  ];
}
