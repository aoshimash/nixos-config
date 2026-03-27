{
  config,
  lib,
  pkgs,
  ...
}:
let
  aqua = pkgs.callPackage ../pkgs/aqua.nix { };
  freelens = pkgs.callPackage ../pkgs/freelens.nix { };
in
{
  imports = [
    ./browsers.nix
    ./hyprland.nix
    ./fcitx5.nix
    ./rofi.nix
    ./cliphist.nix
    ./waybar.nix
    ./wlogout.nix
    ./editors.nix
    ./emacs.nix
    ./mako.nix
    ./shell.nix
    ./tmux.nix
    ./brightness.nix
  ];
  home.username = "aoshima";
  home.homeDirectory = "/home/aoshima";
  home.stateVersion = "25.05";

  catppuccin = {
    # Opt-in per program rather than global enable, to allow incremental migration.
    flavor = "mocha";
    accent = "mauve";
    bat.enable = true;
    lazygit.enable = true;
    k9s.enable = true;
    gtk.icon.enable = true;
  };

  home.packages = with pkgs; [
    # CLI tools
    curl
    unzip
    tree
    htop
    ripgrep
    fd
    jq
    file
    which

    # Development tools
    llvmPackages.clang
    claude-code
    go
    gopls
    python3
    playwright-driver.browsers

    # JavaScript / TypeScript
    bun

    # Python
    uv
    ruff

    # Kubernetes
    kubectl
    freelens
    talosctl
    talhelper
    fluxcd

    # Containers
    ctop

    # AI CLI
    codex
    gemini-cli
    sox # for Claude Code /voice command

    # Switch OpenFit 2+ to HFP for /voice, then back to A2DP when done.
    # Usage: voice-hfp (switches to HFP and waits until ready)
    #        voice-hfp off (switches back to A2DP)
    (pkgs.writeShellScriptBin "voice-hfp" ''
      DEVICE_NAME="bluez_card.A0_0C_E2_15_0C_49"
      HFP_INDEX=196865
      A2DP_INDEX=131076

      dev_id() {
        wpctl status | awk '/OpenFit.*bluez5/ { match($0, /[0-9]+/); print substr($0, RSTART, RLENGTH); exit }'
      }

      case "''${1:-on}" in
        on|hfp)
          ID=$(dev_id)
          [ -z "$ID" ] && echo "OpenFit not connected" && exit 1
          wpctl set-profile "$ID" $HFP_INDEX
          sleep 3
          echo "HFP ready — use /voice now"
          ;;
        off|a2dp)
          ID=$(dev_id)
          [ -z "$ID" ] && echo "OpenFit not connected" && exit 1
          wpctl set-profile "$ID" $A2DP_INDEX
          echo "Switched back to A2DP"
          ;;
        *)
          echo "Usage: voice-hfp [on|off]"
          exit 1
          ;;
      esac
    '')

    # Shell productivity (fzf, zoxide, direnv are in shell.nix via programs.*)
    # bat and lazygit are managed via programs.* for theme configuration
    eza
    delta

    # System info
    dust
    duf

    # Desktop apps
    slack
    obsidian
    bitwarden-desktop
    bambu-studio
    vlc
    thunar

    # Utilities
    yq
    rsync
    aqua
  ];

  home.file.".claude/CLAUDE.md".source = ./dotfiles/claude/CLAUDE.md;

  home.activation.playwrightBrowsers = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    playwright_browsers_store="${pkgs.playwright-driver.browsers}"
    playwright_browsers_dir="$HOME/.playwright-browsers"
    mkdir -p "$playwright_browsers_dir"
    for dir in "$playwright_browsers_store"/*/; do
      ln -sfn "$dir" "$playwright_browsers_dir/$(basename "$dir")"
    done
    chromium_dir=$(ls -d "$playwright_browsers_dir"/chromium-* 2>/dev/null | head -1)
    if [ -n "$chromium_dir" ]; then
      mkdir -p "$playwright_browsers_dir/chromium/chrome-linux64"
      ln -sfn "$chromium_dir/chrome-linux64/chrome" "$playwright_browsers_dir/chromium/chrome-linux64/chrome"
    fi
  '';

  home.activation.claudeSettings =
    let
      baseSettings = builtins.toJSON {
        alwaysThinkingEnabled = true;
        env = {
          CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
          PLAYWRIGHT_BROWSERS_PATH = "${config.home.homeDirectory}/.playwright-browsers";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
        };
        teammateMode = "in-process";
        statusLine = {
          type = "command";
          command = "sh ${config.home.homeDirectory}/.claude/statusline-command.sh";
        };
      };
    in
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      settings_file="${config.home.homeDirectory}/.claude/settings.json"
      installed_plugins_file="${config.home.homeDirectory}/.claude/plugins/installed_plugins.json"
      base_settings='${baseSettings}'
      mkdir -p "$(dirname "$settings_file")"

      # Build enabledPlugins from installed_plugins.json
      if [ -f "$installed_plugins_file" ]; then
        installed_plugins=$(${pkgs.jq}/bin/jq -c '[.plugins // {} | keys[] | {(.): true}] | add // {}' "$installed_plugins_file")
      else
        installed_plugins='{}'
      fi

      # Merge base settings with installed plugins
      echo "$base_settings" | ${pkgs.jq}/bin/jq --argjson plugins "$installed_plugins" '. + {enabledPlugins: $plugins}' > "$settings_file.tmp"
      mv "$settings_file.tmp" "$settings_file"
    '';

  home.file.".claude/statusline-command.sh" = {
    source = ./dotfiles/claude/statusline-command.sh;
    executable = true;
  };

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };

  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  gtk = {
    enable = true;
    # catppuccin/nix does not provide a gtk theme module (upstream port archived),
    # so we use catppuccin-gtk package directly. Name: catppuccin-{flavor}-{accent}-{variant}
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    # iconTheme is managed by catppuccin.gtk.icon (catppuccin-papirus-folders)
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    # Inherit Catppuccin colors from GTK theme (catppuccin/nix lacks Qt support)
    platformTheme.name = "gtk";
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Shuji Aoshima";
    settings.user.email = "47586723+aoshimash@users.noreply.github.com";
  };

  programs.bat = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.k9s = {
    enable = true;
  };
}
