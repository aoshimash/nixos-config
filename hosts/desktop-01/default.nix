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
    ../../modules/bluetooth.nix
    ../../modules/ssh.nix
    ../../modules/xremap.nix
    ../../modules/keyring.nix
    ../../modules/google-drive.nix
    ../../modules/logiops.nix
    ../../modules/scanner.nix
    ../../modules/tailscale.nix
    ../../modules/nix-ld.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes and nix command globally
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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

  # Timezone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # Secrets
  sops.secrets."user-password".neededForUsers = true;
  sops.secrets."wifi-env" = { };

  # User account
  programs.zsh.enable = true;

  users.users.aoshima = {
    isNormalUser = true;
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets."user-password".path;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    nodejs
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Dvorak keyboard layout for TTY
  console.keyMap = "dvorak";

  system.stateVersion = "25.05";
}
