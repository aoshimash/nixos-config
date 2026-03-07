# CLAUDE.md

## Project Overview

NixOS desktop configuration repository using Flakes.
Public repository - never commit secrets or private information.

## Design Principle

Follow "Worse is Better" - prioritize simplicity of implementation over completeness or correctness of the interface. A simpler solution that works is better than a complex one that covers all edge cases.

## Tech Stack

- **NixOS** with **Flakes** (nixpkgs: nixos-unstable)
- **Home Manager** (as NixOS module)
- **Hyprland** (tiling Wayland compositor)
- **sops-nix** for secret management

## Directory Structure

```
hosts/
  desktop-01/          # Main desktop machine
    default.nix
    hardware-configuration.nix
modules/               # Reusable NixOS modules
home/                  # Home Manager configuration
```

## Development Commands

```bash
# Format
nix fmt

# Lint & check
nix flake check

# Build without applying (CI does this on Linux)
nix build .#nixosConfigurations.desktop-01.config.system.build.toplevel

# Apply on NixOS machine
sudo nixos-rebuild switch --flake .#desktop-01

# Secret management
sops secrets/secrets.yaml
```

## Tool Management

- Use **aqua** (`aqua.yaml`) for CLI tools (gitleaks, lefthook, etc.)
- **nixfmt** is not in the aqua registry — install via `brew install nixfmt` (macOS) or Nix
- Keep tool versions consistent between local and CI

## Coding Conventions

### Nix

- Formatter: **nixfmt** (RFC style) - run via `nix fmt`
- Keep modules small and focused on a single concern
- Use `mkOption` with types and descriptions for custom module options

### Git

- **Conventional Commits** (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`)
- **GitHub Flow**: feature branches + PR (early stage: direct push to main is OK)
- Write commit messages in English

### Pre-commit (lefthook)

- `nixfmt --check` on staged `.nix` files
- `gitleaks protect --staged` for secret detection

## Security

- **This is a public repository**
- NEVER commit passwords, private keys, API tokens, WiFi PSK, or `hashedPassword`
- Use **sops-nix** for any secrets that need to be in the repo
- gitleaks runs on pre-commit and CI to prevent accidental leaks

## CI (GitHub Actions)

- Format check (`nixfmt --check`)
- Secret detection (`gitleaks`)
- NixOS build check (Linux runner)

## Testing Strategy

- **Mac (editing)**: format, lint, gitleaks, `nix flake check` (partial)
- **CI (Linux)**: full build check
- **NixOS machine**: `nixos-rebuild switch` (final apply)
