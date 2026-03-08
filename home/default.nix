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
    ./wofi.nix
    ./waybar.nix
    ./editors.nix
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

    # Python
    uv
    ruff

    # Kubernetes
    kubectl
    k9s
    freelens

    # Containers
    ctop

    # AI CLI
    codex
    gemini-cli

    # Shell productivity (fzf, zoxide, direnv are in shell.nix via programs.*)
    bat
    eza
    lazygit
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

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Shuji Aoshima";
    settings.user.email = "47586723+aoshimash@users.noreply.github.com";
  };
}
