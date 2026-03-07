{ config, pkgs, ... }:
{
  # Allow unfree packages (e.g. NVIDIA driver)
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/hyprland.nix
    ../../modules/sops.nix
    ../../modules/fonts.nix
    ../../modules/audio.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "desktop-01";
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets."wifi-env".path ];
    profiles.home-wifi = {
      connection = {
        id = "home-wifi";
        type = "wifi";
      };
      wifi = {
        ssid = "$WIFI_SSID";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "sae";
        psk = "$WIFI_PSK";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Timezone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # Secrets
  sops.secrets."user-password".neededForUsers = true;
  sops.secrets."wifi-env" = { };

  # User account
  users.users.aoshima = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."user-password".path;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  # Dvorak keyboard layout for TTY
  console.keyMap = "dvorak";

  system.stateVersion = "25.05";
}
