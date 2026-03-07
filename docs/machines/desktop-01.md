# desktop-01: ThinkStation P3 Ultra SFF Gen 2

Machine-specific reference for reproducing the NixOS installation on this hardware.

## Hardware

| Component | Detail |
|-----------|--------|
| Model | Lenovo ThinkStation P3 Ultra SFF Gen 2 |
| Disk | NVMe SSD (`/dev/nvme0n1`, ~954 GB) |

## BIOS/UEFI Notes

- **Secure Boot** must be disabled (NixOS minimal ISO does not support it)

## Partition Layout

Created during installation (see [installation.md](../installation.md) Step 4):

| Partition | Label | Type | Size | Mount |
|-----------|-------|------|------|-------|
| `nvme0n1p1` | `nixos` | ext4 | ~953 GB | `/` |
| `nvme0n1p2` | `boot` | FAT32 | 512 MB | `/boot` |

## Monitor Configuration

Identified via `hyprctl monitors` (see [setup.md](../setup.md) Post-Boot Steps):

| Output | Resolution | Position | Scale | Monitor |
|--------|-----------|----------|-------|---------|
| `DP-6` | 2560x1440@144 | 0x0 | 1 | JAPANNEXT (left) |
| `DP-9` | 2560x1440@144 | 2560x0 | 1 | DELL G3223D (center) |
| `DP-8` | 3840x2160@60 | 5120x0 | 1.5 | LG HDR 4K (right) |

> **Note:** Monitor output names (DP-6, DP-9, DP-8) may change if cables are moved to different ports. Run `hyprctl monitors` to re-identify them.

## Installation Notes

Lessons learned from the initial installation (2026-03):

- The NixOS live environment requires `sudo` for all disk/mount/install operations
- Cloning the repo to `/mnt/etc/nixos-config` requires `sudo nix-shell -p git --run "git clone ..."`
- After installation, clone the repo to `~/nixos-config` for daily use and remove `/etc/nixos-config`
- Age key transfer via `scp` from Mac works well (Mac needs Remote Login enabled)
