{ pkgs, ... }:
{
  # Allow unfree packages (e.g. NVIDIA driver)
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "desktop-01";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Timezone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # User account
  users.users.aoshima = {
    isNormalUser = true;
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

  system.stateVersion = "25.05";
}
