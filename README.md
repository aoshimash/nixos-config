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

## Secret Management

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using age encryption.

### Initial Setup (Mac)

1. Install `age` and `sops` (managed via aqua)
2. Generate an age key:
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```
3. Add to your shell profile:
   ```bash
   export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
   ```

### Initial Setup (NixOS)

Copy the age secret key to the NixOS machine:

```bash
# On the NixOS machine
sudo mkdir -p /var/lib/sops-nix
sudo cp keys.txt /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
```

Then apply the configuration:

```bash
sudo nixos-rebuild switch --flake .#desktop-01
```

### Editing Secrets

```bash
sops secrets/secrets.yaml
```

This opens the decrypted file in your editor. It is automatically re-encrypted on save.

### Adding a New Host Key

After NixOS installation, add the host's SSH key to `.sops.yaml` for redundancy:

```bash
# On the NixOS machine
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Add the output to `.sops.yaml` and re-encrypt:

```bash
sops updatekeys secrets/secrets.yaml
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
