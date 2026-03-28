{ pkgs, ... }:
{
  catppuccin.zsh-syntax-highlighting.enable = true;
  catppuccin.starship.enable = true;
  catppuccin.fzf.enable = true;

  home.packages = [
    pkgs.zsh-completions
    pkgs.semgrep
    pkgs.tig
    pkgs.lsof
  ];

  programs.zsh = {
    enable = true;

    history = {
      size = 100000;
      save = 100000;
      share = true;
      extended = true;
    };

    sessionVariables = {
      EDITOR = "emacs -nw";
      VISUAL = "emacs";
    };

    initContent = ''
      # aqua - add shim directory to PATH
      export PATH="''${AQUA_ROOT_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

      # bun - global bin directory
      export PATH="$HOME/.cache/.bun/bin:$PATH"

      # Emacs keybind
      bindkey -e

      # Options
      setopt notify
      setopt extendedglob
      setopt correct
      setopt HIST_NO_STORE
      setopt ignore_eof
    '';

    shellAliases = {
      grep = "grep --color=auto";
      ls = "ls --color=auto";
      k = "kubectl";
      ksec = "kubesec";
      wk = "watch kubectl";
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "cursor"
      ];
    };
    autosuggestion.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      aws.style = "bold peach";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      cmd_duration.style = "bold yellow";
      directory.style = "bold blue";
      git_branch.style = "bold sky";
      git_status.style = "bold yellow";
      hostname.style = "bold pink";
      username.style_user = "bold pink";

      custom.worktree = {
        command = "git rev-parse --git-dir 2>/dev/null | sed 's|.*/worktrees/||'";
        when = "git rev-parse --git-dir 2>/dev/null | grep -q /worktrees/";
        format = "[⎇ $output]($style) ";
        style = "bold peach";
      };
    };
  };
  programs.zoxide.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # nix-index is enabled via nix-index-database in flake.nix
  programs.nix-index-database.comma.enable = true;
}
