# Catppuccin Mocha Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all hardcoded Dracula colors with `catppuccin/nix` declarative theming, achieving consistent GTK/Qt/Wayland-native appearance using Catppuccin Mocha with mauve accent.

**Architecture:** Add `catppuccin/nix` as a flake input and import its home-manager module. Set global flavor/accent once in `home/default.nix`, then enable per-program with `catppuccin.enable = true`. Strip all hardcoded Dracula hex values from CSS and Nix configs; use catppuccin CSS variables (`@mauve`, `@red`, etc.) where structural colors are needed in CSS.

**Tech Stack:** NixOS Flakes, home-manager, catppuccin/nix (`github:catppuccin/nix`), nixfmt (RFC style)

**Working directory:** All commands run from the worktree root:
`.worktrees/feat/catppuccin-migration/` inside the repository.

---

### Task 1: Add catppuccin/nix flake input and home-manager module

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add catppuccin to inputs and outputs signature**

Replace the `inputs` block and `outputs` signature in `flake.nix`:

```nix
{
  description = "NixOS configuration for desktop-01";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      nix-index-database,
      xremap-flake,
      catppuccin,
      ...
    }:
```

- [ ] **Step 2: Add catppuccin home-manager module to imports**

In the `home-manager.users.aoshima` block, add the module:

```nix
home-manager.users.aoshima = {
  imports = [
    nix-index-database.homeModules.nix-index
    catppuccin.homeManagerModules.catppuccin
    ./home
  ];
};
```

- [ ] **Step 3: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: a `/nix/store/...` path is printed (no errors).

- [ ] **Step 4: Commit**

```bash
git add flake.nix
git commit -m "feat: add catppuccin/nix flake input and home-manager module"
```

---

### Task 2: Set global catppuccin defaults, enable GTK and Qt theming

**Files:**
- Modify: `home/default.nix`

- [ ] **Step 1: Add global catppuccin settings**

Add the following block directly under `home.stateVersion = "25.05";`:

```nix
catppuccin = {
  flavor = "mocha";
  accent = "mauve";
};
```

- [ ] **Step 2: Replace the gtk block**

Find and replace the existing `gtk` block (lines 195–201 in the original file):

```nix
gtk = {
  enable = true;
  catppuccin.enable = true;
  iconTheme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };
  gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = 1;
  };
};
```

- [ ] **Step 3: Add qt block after gtk**

```nix
qt = {
  enable = true;
  catppuccin.enable = true;
};
```

- [ ] **Step 4: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: store path printed, no errors.

- [ ] **Step 5: Commit**

```bash
git add home/default.nix
git commit -m "feat: set global catppuccin mocha/mauve defaults and enable GTK/Qt theming"
```

---

### Task 3: Migrate mako, bat, lazygit, and k9s

**Files:**
- Modify: `home/mako.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Replace home/mako.nix**

Replace the entire file content:

```nix
{ ... }:
{
  services.mako = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      default-timeout = 5000;
      anchor = "top-right";
      border-radius = 8;
    };
  };
}
```

- [ ] **Step 2: Replace programs.bat in home/default.nix**

Find and replace the `programs.bat` block:

```nix
programs.bat = {
  enable = true;
  catppuccin.enable = true;
};
```

- [ ] **Step 3: Replace programs.lazygit in home/default.nix**

Find and replace the entire `programs.lazygit` block (including all nested `settings`):

```nix
programs.lazygit = {
  enable = true;
  catppuccin.enable = true;
};
```

- [ ] **Step 4: Replace programs.k9s in home/default.nix**

Find and replace the entire `programs.k9s` block (including `settings` and `skins`):

```nix
programs.k9s = {
  enable = true;
  catppuccin.enable = true;
};
```

- [ ] **Step 5: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: store path printed, no errors.

- [ ] **Step 6: Commit**

```bash
git add home/mako.nix home/default.nix
git commit -m "feat: migrate mako, bat, lazygit, k9s to catppuccin theming"
```

---

### Task 4: Migrate ghostty, hyprlock, and hyprland borders

**Files:**
- Modify: `home/hyprland.nix`

- [ ] **Step 1: Add catppuccin.enable to wayland.windowManager.hyprland**

In the `wayland.windowManager.hyprland` block, add `catppuccin.enable = true` and remove the `general` block (which only contained color settings):

```nix
wayland.windowManager.hyprland = {
  enable = true;
  catppuccin.enable = true;
  systemd.enable = false;
  settings = {
    # monitor, workspace, env, cursor, input, exec-once unchanged
    # general block removed — col.active_border and col.inactive_border
    # are now handled by catppuccin

    decoration.blur = {
      enabled = true;
      size = 5;
      passes = 2;
    };

    layerrule = [
      "blur on, match:namespace waybar"
    ];

    # ... rest of settings unchanged (bind, bindl, bindm, etc.)
  };
};
```

- [ ] **Step 2: Update programs.ghostty**

Find and replace the `programs.ghostty` block:

```nix
programs.ghostty = {
  enable = true;
  catppuccin.enable = true;
  settings = {
    font-family = "HackGen35 Console NF";
    font-size = 12;
  };
};
```

- [ ] **Step 3: Update programs.hyprlock**

Find and replace the `programs.hyprlock` block. Remove `outer_color`, `inner_color`, and `font_color` from `input-field` — catppuccin handles these:

```nix
programs.hyprlock = {
  enable = true;
  catppuccin.enable = true;
  settings = {
    general = {
      hide_cursor = true;
    };
    background = [
      {
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }
    ];
    input-field = [
      {
        monitor = "";
        size = "200, 50";
        outline_thickness = 3;
        dots_size = 0.33;
        dots_spacing = 0.15;
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
      }
    ];
  };
};
```

- [ ] **Step 4: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: store path printed, no errors.

- [ ] **Step 5: Commit**

```bash
git add home/hyprland.nix
git commit -m "feat: migrate ghostty, hyprlock, hyprland borders to catppuccin theming"
```

---

### Task 5: Migrate rofi and remove dracula.rasi

**Files:**
- Modify: `home/rofi.nix`
- Delete: `home/dotfiles/rofi/dracula.rasi`

- [ ] **Step 1: Replace home/rofi.nix**

```nix
{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
    package = pkgs.rofi;
    terminal = "ghostty";
  };
}
```

- [ ] **Step 2: Delete the dracula.rasi file**

```bash
git rm home/dotfiles/rofi/dracula.rasi
```

- [ ] **Step 3: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: store path printed, no errors.

- [ ] **Step 4: Commit**

```bash
git add home/rofi.nix
git commit -m "feat: migrate rofi to catppuccin theming, remove dracula.rasi"
```

---

### Task 6: Migrate waybar CSS

**Files:**
- Modify: `home/waybar.nix`

- [ ] **Step 1: Add catppuccin.enable and replace style block**

Add `catppuccin.enable = true;` inside the `programs.waybar` block, and replace the entire `style` string with the layout-only version below. Colors that are structural (active border, power button) use catppuccin CSS variables injected by the module (`@mauve`, `@red`, `@text`, `@surface1`, `alpha(@red, 0.25)`).

```nix
programs.waybar = {
  enable = true;
  catppuccin.enable = true;

  style = ''
    * {
      font-family: "HackGen35 Console NF", monospace;
      font-size: 13px;
      min-height: 0;
    }

    #workspaces button {
      padding: 0 10px;
      min-width: 24px;
      margin: 4px 2px;
      border-radius: 4px;
      border: none;
    }

    #workspaces button.visible {
      border-bottom: 2px solid @surface1;
    }

    #workspaces button.active {
      border-bottom: 2px solid @mauve;
    }

    #clock,
    #network,
    #pulseaudio,
    #bluetooth,
    #tray,
    #custom-power {
      padding: 0 10px;
    }

    #pulseaudio-slider {
      min-width: 120px;
      padding: 0 5px;
    }

    #pulseaudio-slider trough {
      min-height: 8px;
      border-radius: 4px;
    }

    #pulseaudio-slider highlight {
      min-height: 8px;
      border-radius: 4px;
    }

    #custom-power {
      color: @red;
    }

    #custom-power:hover {
      color: @text;
      background: alpha(@red, 0.25);
      border-radius: 4px;
    }
  '';

  # settings block: keep entirely as-is from the current file.
  # The only changes to home/waybar.nix are:
  #   1. Add catppuccin.enable = true (shown above)
  #   2. Replace the style string (shown above)
  # Do not touch settings.mainBar or any module config.
};
```

- [ ] **Step 2: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: store path printed, no errors.

- [ ] **Step 3: Commit**

```bash
git add home/waybar.nix
git commit -m "feat: migrate waybar to catppuccin theming, strip hardcoded Dracula colors"
```

---

### Task 7: Migrate wlogout CSS

**Files:**
- Modify: `home/wlogout.nix`

- [ ] **Step 1: Add catppuccin.enable and replace style block**

Add `catppuccin.enable = true;` and replace the `style` string with layout-only CSS. The catppuccin/nix wlogout module handles semantic button colors (lock=blue, logout=green, suspend=yellow, reboot=peach, shutdown=red) automatically.

```nix
programs.wlogout = {
  enable = true;
  catppuccin.enable = true;

  layout = [
    {
      label = "lock";
      action = "hyprlock";
      text = "󰌾  Lock";
      keybind = "l";
    }
    {
      label = "logout";
      action = "hyprctl dispatch exit";
      text = "󰍃  Logout";
      keybind = "e";
    }
    {
      label = "suspend";
      action = "systemctl suspend";
      text = "󰤄  Suspend";
      keybind = "u";
    }
    {
      label = "reboot";
      action = "systemctl reboot";
      text = "󰜉  Reboot";
      keybind = "r";
    }
    {
      label = "shutdown";
      action = "systemctl poweroff";
      text = "󰐥  Shutdown";
      keybind = "s";
    }
  ];

  style = ''
    * {
      background-image: none;
      font-family: "HackGen35 Console NF", monospace;
      font-size: 16px;
    }

    button {
      border: none;
      border-radius: 12px;
      margin: 10px;
    }
  '';
};
```

- [ ] **Step 2: Format and evaluate**

```bash
nix fmt
nix eval .#nixosConfigurations.desktop-01.config.system.build.toplevel
```

Expected: store path printed, no errors.

- [ ] **Step 3: Run full flake check**

```bash
nix flake check
```

Expected: exits with code 0, no evaluation errors.

- [ ] **Step 4: Commit**

```bash
git add home/wlogout.nix
git commit -m "feat: migrate wlogout to catppuccin theming, strip hardcoded Dracula colors"
```

---

### Task 8: Final verification and push

- [ ] **Step 1: Confirm all Dracula hex codes are gone**

```bash
grep -rE "#282a36|#f8f8f2|#bd93f9|#44475a|#6272a4|#ff5555|#50fa7b|#8be9fd|#ffb86c|#ff79c6|rgba\(40, 42|rgba\(189, 147|rgb\(189|rgb\(40|[Dd]racula" \
  home/ --include="*.nix" -l
```

Expected: no output (no files match).

- [ ] **Step 2: Run full flake check**

```bash
nix flake check
```

Expected: exits with code 0.

- [ ] **Step 3: Push branch**

```bash
git push -u origin feat/catppuccin-migration
```

- [ ] **Step 4: Open PR**

```bash
gh pr create \
  --title "Migrate desktop theme from Dracula to Catppuccin Mocha" \
  --body "Closes #151 (partial — theming unification complete; WiFi/BT system controls remain)" \
  --base main
```

- [ ] **Step 5: Visual verification on NixOS machine** (after PR merge and nixos-rebuild)

Apply the configuration:
```bash
sudo nixos-rebuild switch --flake .#desktop-01
```

Verify visually:
- Thunar / pavucontrol render with Catppuccin Mocha dark background
- VLC renders with dark theme (Qt)
- Waybar shows mauve accent on active workspace
- Mako notifications appear with Catppuccin Mocha style
- Rofi launcher shows Catppuccin Mocha colors
- Ghostty terminal uses Catppuccin Mocha
- Hyprlock shows Catppuccin Mocha input field
- wlogout shows semantic button colors (lock=blue, shutdown=red)
- Hyprland window borders show mauve gradient
