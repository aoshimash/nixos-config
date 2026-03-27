# Catppuccin Mocha Migration Design

**Date:** 2026-03-27
**Branch:** feat/catppuccin-migration
**Related issue:** #151

## Summary

Migrate the desktop theme from manually hardcoded Dracula colors to `catppuccin/nix`, achieving
declarative, consistent theming across all GUI layers (GTK, Qt, Wayland-native tools) using
Catppuccin Mocha with mauve accent.

## Motivation

All Wayland-layer components (Waybar, Mako, Rofi, Ghostty, Hyprlock, Hyprland borders) currently
use Dracula colors hardcoded as hex values spread across multiple files. GTK apps default to
Adwaita light and Qt apps have no theme at all, causing visible inconsistency when opening any
native GUI application. `catppuccin/nix` provides home-manager modules that eliminate per-tool
manual color management and automatically cover GTK and Qt theming.

## Architecture

`catppuccin/nix` is added as a flake input and its `homeManagerModules.catppuccin` is registered
as a home-manager import. This makes `catppuccin.enable`, `catppuccin.flavor`, and
`catppuccin.accent` options available on all supported programs. Global defaults are set once;
individual programs inherit them.

```
flake.nix
  inputs.catppuccin = { url = "github:catppuccin/nix"; }

home-manager imports
  catppuccin.homeManagerModules.catppuccin

home/default.nix (global defaults)
  catppuccin.flavor = "mocha"
  catppuccin.accent = "mauve"
  gtk.catppuccin.enable = true
  qt.catppuccin.enable  = true
```

## File-by-File Changes

### flake.nix
- Add `catppuccin` to `inputs`
- Pass `catppuccin` through to outputs
- Add `catppuccin.homeManagerModules.catppuccin` to home-manager imports

### home/default.nix
- Set global `catppuccin.flavor = "mocha"` and `catppuccin.accent = "mauve"`
- Replace existing `gtk` block: keep icon theme, add `gtk.catppuccin.enable = true` and
  `gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1`
- Add `qt` block: `qt.enable = true`, `qt.catppuccin.enable = true`
- Enable catppuccin for `programs.bat`, `programs.lazygit`, `programs.k9s`
- Remove all manually specified Dracula color values from bat/lazygit/k9s configs

### home/mako.nix
- Replace manual color settings (`background-color`, `text-color`, `border-color`) with
  `catppuccin.enable = true`
- Keep non-color settings: `default-timeout`, `anchor`, `border-radius`

### home/waybar.nix
- Add `catppuccin.enable = true`
- Remove color-only CSS properties from `style`:
  - `background: rgba(...)` on `window#waybar`
  - `color: ...` properties
  - `background-color: rgba(...)` on workspace buttons
  - `border-bottom: 2px solid #...` accent colors
  - `background-color: #bd93f9` on slider highlight
  - Color values in `#custom-power`
- Keep all non-color CSS: `font-family`, `font-size`, `min-height`, `padding`, `margin`,
  `border-radius`, `min-width`, sizing properties

### home/wlogout.nix
- Add `catppuccin.enable = true`
- Remove color-only CSS from `style`:
  - `background-color` on `window`
  - `color` and `background-color` on `button` and `button:hover`/`button:focus`
  - All `#lock`, `#logout`, `#suspend`, `#reboot`, `#shutdown` color blocks
- Keep non-color CSS: `font-family`, `font-size`, `border-radius`, `margin`, `border: none`

### home/hyprland.nix
- Add `wayland.windowManager.hyprland.catppuccin.enable = true`
  → replaces `col.active_border` and `col.inactive_border` hardcoded values in `general`
- Add `programs.ghostty.catppuccin.enable = true`
  → replaces `theme = "Dracula"` in ghostty settings
- Add `programs.hyprlock.catppuccin.enable = true`
  → replaces manually specified `outer_color`, `inner_color`, `font_color` in input-field

### home/rofi.nix
- Add `catppuccin.enable = true`
- Remove `theme = ./dotfiles/rofi/dracula.rasi` reference

### home/dotfiles/rofi/dracula.rasi
- Delete file (replaced by catppuccin/nix generated theme)

## What Stays Manual

The following CSS properties are **not colors** and must remain in the custom `style` blocks:

- `font-family`, `font-size` — typography
- `padding`, `margin` — spacing
- `border-radius` — shape
- `min-width`, `min-height`, `height` — sizing
- `border: none` — structural (removes default border entirely)
- `transition-duration` — animation

## Out of Scope

- WiFi/Bluetooth system controls UI (tracked separately in issue #151)
- GTK font unification (can be added to `home/default.nix` as a follow-up)
- Cursor theme change (Bibata-Modern-Classic already set and consistent)
- Electron app theming (Slack, Obsidian, VSCode — follow system dark mode signal automatically
  once `gtk-application-prefer-dark-theme = 1` is set)

## Testing

1. `nix fmt` — format check passes
2. `nix flake check` — config evaluates without errors
3. `nix build .#nixosConfigurations.desktop-01.config.system.build.toplevel` — full build
4. `nixos-rebuild switch --flake .#desktop-01` — apply and visually verify:
   - GTK apps (Thunar, pavucontrol) render with Catppuccin Mocha dark theme
   - Qt apps (VLC) render with dark theme
   - Waybar, Mako, Rofi, Ghostty, Hyprlock, wlogout all show Catppuccin Mocha colors
   - Hyprland window borders show mauve accent
