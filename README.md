# nixos-config

My NixOS desktop configuration managed with Flakes.

## Hosts

| Host | Description |
|---|---|
| `desktop-01` | Main desktop machine (Hyprland) |

## Tech Stack

- NixOS (nixos-unstable) with Flakes
- Home Manager
- Hyprland (tiling Wayland compositor)
- sops-nix (secret management)

## Usage

```bash
# Apply configuration on NixOS machine
sudo nixos-rebuild switch --flake .#desktop-01

# Format
nix fmt

# Check
nix flake check
```

## Development

### Prerequisites

- [aqua](https://aquaproj.github.io/) for tool management

### Setup

```bash
aqua install
lefthook install
```

### Pre-commit Hooks

Managed by [lefthook](https://github.com/evilmartians/lefthook):

- `nixfmt --check` - Nix code formatting
- `gitleaks protect --staged` - Secret detection

## License

MIT
