{ config, pkgs, ... }:
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
  ];
  home.username = "aoshima";
  home.homeDirectory = "/home/aoshima";
  home.stateVersion = "25.05";

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
        pw-cli list-objects 2>/dev/null \
          | awk -v dev="$DEVICE_NAME" '
              /^id [0-9]/ { id = $2 }
              $0 ~ dev     { print id; exit }
            ' | tr -d ','
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

  home.activation.claudeSettings =
    let
      baseSettings = builtins.toJSON {
        alwaysThinkingEnabled = true;
        env = {
          CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
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

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
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
    config.theme = "Dracula";
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [
          "#bd93f9"
          "bold"
        ];
        inactiveBorderColor = [ "#6272a4" ];
        optionsTextColor = [ "#8be9fd" ];
        selectedLineBgColor = [ "#44475a" ];
        selectedRangeBgColor = [ "#44475a" ];
        cherryPickedCommitBgColor = [ "#44475a" ];
        cherryPickedCommitFgColor = [ "#bd93f9" ];
        unstagedChangesColor = [ "#ff5555" ];
        defaultFgColor = [ "#f8f8f2" ];
        searchingActiveBorderColor = [ "#ffb86c" ];
      };
    };
  };

  programs.k9s = {
    enable = true;
    settings = {
      k9s.ui.skin = "dracula";
    };
    skins = {
      dracula = {
        k9s = {
          body = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            logoColor = "#bd93f9";
          };
          frame = {
            border = {
              fgColor = "#44475a";
              focusColor = "#bd93f9";
            };
            menu = {
              fgColor = "#f8f8f2";
              keyColor = "#8be9fd";
              numKeyColor = "#ffb86c";
            };
            crumbs = {
              fgColor = "#f8f8f2";
              bgColor = "#44475a";
              activeColor = "#bd93f9";
            };
            status = {
              newColor = "#50fa7b";
              modifyColor = "#8be9fd";
              addColor = "#50fa7b";
              errorColor = "#ff5555";
              highlightColor = "#ffb86c";
              killColor = "#ff5555";
              completedColor = "#6272a4";
            };
            title = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              highlightColor = "#ffb86c";
              counterColor = "#8be9fd";
              filterColor = "#8be9fd";
            };
          };
          views = {
            table = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              markColor = "#ffb86c";
              header = {
                fgColor = "#8be9fd";
                bgColor = "#282a36";
                sorterColor = "#ffb86c";
              };
            };
            xray = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              cursorColor = "#44475a";
              graphicColor = "#bd93f9";
              showIcons = false;
            };
            yaml = {
              keyColor = "#8be9fd";
              colonColor = "#f8f8f2";
              valueColor = "#f8f8f2";
            };
            logs = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              indicator = {
                fgColor = "#f8f8f2";
                bgColor = "#bd93f9";
              };
            };
          };
        };
      };
    };
  };
}
