# NixOS Installation Guide

This guide covers the complete NixOS installation process from USB boot media creation to `nixos-install`, specific to this repository's `desktop-01` configuration.

For post-install configuration (applying the flake, setting up monitors, etc.), see [setup.md](setup.md).

## Prerequisites

- A USB drive (2 GB or larger)
- A Mac for creating the boot media
- The target machine with **wired (Ethernet) connection**
- Access to the age secret key (`~/.config/sops/age/keys.txt` on your Mac)

## Step 1: Create USB Boot Media (from macOS)

Download the latest NixOS minimal ISO from https://nixos.org/download/:

```bash
# Example (adjust URL for the latest version)
curl -L -o nixos-minimal.iso https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
```

Identify the USB drive:

```bash
diskutil list
```

Find your USB drive (e.g., `/dev/disk4`). **Double-check the disk number** — writing to the wrong disk will destroy data.

Unmount the USB drive and write the ISO:

```bash
diskutil unmountDisk /dev/diskN
sudo dd if=nixos-minimal.iso of=/dev/rdiskN bs=4m status=progress
```

> **Note:** Use `/dev/rdiskN` (with the `r` prefix) for significantly faster writes.

## Step 2: Boot from USB

1. Insert the USB drive into the target machine.
2. Enter the BIOS/UEFI settings and **disable Secure Boot** (typically under Security or Boot tab). NixOS minimal ISO does not support Secure Boot.
3. Enter the BIOS/UEFI boot menu (typically by pressing F12, F2, or Del during startup).
4. Select the USB drive as the boot device (UEFI mode).
5. NixOS will boot into a minimal environment with a root shell.

## Step 3: Connect to the Network

Verify wired Ethernet connectivity:

```bash
ping -c 3 nixos.org
```

If using Wi-Fi temporarily (the final system uses sops-nix managed credentials):

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YOUR_SSID"
> set_network 0 psk "YOUR_PSK"
> enable_network 0
> quit
```

## Step 4: Partition and Format the Disk

This configuration uses UEFI with systemd-boot. Create a GPT partition table with an EFI System Partition and a root partition.

1. Identify the target disk:

   ```bash
   lsblk
   ```

2. Partition the disk (example using `/dev/nvme0n1`):

   ```bash
   sudo parted /dev/nvme0n1 -- mklabel gpt
   sudo parted /dev/nvme0n1 -- mkpart root ext4 512MB 100%
   sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
   sudo parted /dev/nvme0n1 -- set 2 esp on
   ```

3. Format the partitions:

   ```bash
   sudo mkfs.ext4 -L nixos /dev/nvme0n1p1
   sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p2
   ```

4. Mount the partitions:

   ```bash
   sudo mount /dev/disk/by-label/nixos /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/disk/by-label/boot /mnt/boot
   ```

## Step 5: Generate hardware-configuration.nix

1. Generate the hardware configuration for the target machine:

   ```bash
   sudo nixos-generate-config --root /mnt
   ```

   This creates `/mnt/etc/nixos/hardware-configuration.nix` with the correct hardware settings for your machine.

2. Clone this repository:

   ```bash
   sudo nix-shell -p git --run "git clone https://github.com/aoshimash/nixos-config.git /mnt/etc/nixos-config"
   ```

3. Replace the placeholder `hardware-configuration.nix` with the generated one:

   ```bash
   sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos-config/hosts/desktop-01/hardware-configuration.nix
   ```

   > **Important:** After installation, commit this file to the repository so future rebuilds use the correct hardware configuration.

## Step 6: Transfer the Age Decryption Key

The sops-nix secrets (user password, Wi-Fi credentials) require the age decryption key to be present during installation.

On your Mac, enable **Remote Login** (System Settings > General > Sharing > Remote Login).

On the NixOS installer, copy the key from your Mac:

```bash
sudo mkdir -p /mnt/var/lib/sops-nix
sudo scp <mac-user>@<Mac-IP>:~/.config/sops/age/keys.txt /mnt/var/lib/sops-nix/key.txt
sudo chmod 600 /mnt/var/lib/sops-nix/key.txt
```

> **Note:** The key must be at `/mnt/var/lib/sops-nix/key.txt` (under `/mnt`) during installation. After boot, it will be at `/var/lib/sops-nix/key.txt` as configured in `modules/sops.nix`.

## Step 7: Install NixOS

Run the installation from the cloned repository:

```bash
sudo nixos-install --flake /mnt/etc/nixos-config#desktop-01
```

You will be prompted to set the root password. The user password for `aoshima` is managed by sops-nix and will be set automatically.

> **Note:** The first install may take a while as it fetches and builds all dependencies.

## Step 8: Reboot

```bash
reboot
```

Remove the USB drive when prompted or during the reboot.

## Next Steps

After booting into the installed system:

1. Clone the repository to your home directory for day-to-day use:

   ```bash
   cd ~
   git clone https://github.com/aoshimash/nixos-config.git
   ```

   The `/etc/nixos-config` clone from installation is no longer needed and can be removed:

   ```bash
   sudo rm -rf /etc/nixos-config
   ```

2. Follow the [Setup Guide](setup.md) for post-install configuration:
   - Identifying and configuring monitor output names for Hyprland
   - Troubleshooting common issues
