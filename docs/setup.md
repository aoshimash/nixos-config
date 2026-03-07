# Setup Guide

This guide walks through the complete process of deploying the nixos-config on a fresh or existing NixOS installation.

## Prerequisites

- A machine running NixOS (with a standard installation completed)
- **Wired (Ethernet) connection** — Wi-Fi credentials are managed by sops-nix and won't be available until after the first successful build
- Git installed on the NixOS machine

## Step 1: Clone the Repository

```bash
git clone https://github.com/aoshimash/nixos-config.git
cd nixos-config
```

## Step 2: Set Up Secret Decryption Key

The NixOS configuration depends on sops-nix secrets (e.g., user password, Wi-Fi credentials). The age decryption key must be in place before applying the configuration.

Copy the age secret key to the NixOS machine (see [Secret Management](../README.md#secret-management) for how to generate one):

```bash
sudo mkdir -p /var/lib/sops-nix
sudo cp keys.txt /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
```

## Step 3: Apply the Configuration

```bash
sudo nixos-rebuild switch --flake .#desktop-01
```

This will download all required packages and apply the full system configuration including Hyprland, Home Manager settings, and all configured modules.

> **Note:** The first build may take a while as it fetches and builds all dependencies.

## Step 4: Reboot

After the configuration is applied, reboot the machine:

```bash
sudo reboot
```

## Post-Boot Steps

### Identify and Replace Monitor Output Names

The Hyprland configuration in `home/hyprland.nix` ships with placeholder monitor names (`PLACEHOLDER-1`, `PLACEHOLDER-2`, `PLACEHOLDER-3`) that must be replaced with the actual output names for your hardware.

1. After booting into Hyprland, open a terminal (`Super + Return`) and run:

   ```bash
   hyprctl monitors
   ```

   This lists all connected monitors with their output names (e.g., `DP-1`, `HDMI-A-1`).

   > **Tip:** If Hyprland fails to start or you are in a TTY, you can also check available outputs with:
   > ```bash
   > # From a TTY (without a running compositor)
   > cat /sys/class/drm/card*/status
   > ls /sys/class/drm/
   > ```

2. Edit `home/hyprland.nix` and replace the placeholder values in the `monitor` list:

   ```nix
   monitor = [
     "DP-1, 2560x1440@144, 0x0, 1"        # JAPANNEXT (left)
     "DP-2, 2560x1440@144, 2560x0, 1"      # DELL G3223D (center)
     "HDMI-A-1, 3840x2160@60, 5120x0, 1.5" # LG HDR 4K (right)
   ];
   ```

   Replace `DP-1`, `DP-2`, and `HDMI-A-1` with the actual output names from `hyprctl monitors`.

3. Rebuild and apply:

   ```bash
   sudo nixos-rebuild switch --flake .#desktop-01
   ```

## Troubleshooting

### Hyprland does not start

- Check that your GPU drivers are properly configured in `hosts/desktop-01/default.nix`.
- Review the Hyprland log: `cat /tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log`

### Monitor not detected

- Verify the cable connection and that the monitor is powered on.
- Check kernel-level detection: `cat /sys/class/drm/card*/status`
- Try a different port or cable if a monitor shows as "disconnected".
