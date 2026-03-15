{ pkgs, ... }:
{
  home.packages = [ pkgs.zsh-completions ];

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
      styles = {
        # Comments
        comment = "fg=#6272A4";
        # Functions/methods
        alias = "fg=#50FA7B";
        suffix-alias = "fg=#50FA7B";
        global-alias = "fg=#50FA7B";
        function = "fg=#50FA7B";
        command = "fg=#50FA7B";
        precommand = "fg=#50FA7B,italic";
        autodirectory = "fg=#FFB86C,italic";
        single-hyphen-option = "fg=#FFB86C";
        double-hyphen-option = "fg=#FFB86C";
        back-quoted-argument = "fg=#BD93F9";
        # Built ins
        builtin = "fg=#8BE9FD";
        reserved-word = "fg=#8BE9FD";
        hashed-command = "fg=#8BE9FD";
        # Punctuation
        commandseparator = "fg=#FF79C6";
        command-substitution-delimiter = "fg=#F8F8F2";
        command-substitution-delimiter-unquoted = "fg=#F8F8F2";
        process-substitution-delimiter = "fg=#F8F8F2";
        back-quoted-argument-delimiter = "fg=#FF79C6";
        back-double-quoted-argument = "fg=#FF79C6";
        back-dollar-quoted-argument = "fg=#FF79C6";
        # Strings
        command-substitution-quoted = "fg=#F1FA8C";
        command-substitution-delimiter-quoted = "fg=#F1FA8C";
        single-quoted-argument = "fg=#F1FA8C";
        single-quoted-argument-unclosed = "fg=#FF5555";
        double-quoted-argument = "fg=#F1FA8C";
        double-quoted-argument-unclosed = "fg=#FF5555";
        rc-quote = "fg=#F1FA8C";
        # Variables
        dollar-quoted-argument = "fg=#F8F8F2";
        dollar-quoted-argument-unclosed = "fg=#FF5555";
        dollar-double-quoted-argument = "fg=#F8F8F2";
        assign = "fg=#F8F8F2";
        named-fd = "fg=#F8F8F2";
        numeric-fd = "fg=#F8F8F2";
        # Other
        unknown-token = "fg=#FF5555";
        path = "fg=#F8F8F2";
        path_pathseparator = "fg=#FF79C6";
        path_prefix = "fg=#F8F8F2";
        path_prefix_pathseparator = "fg=#FF79C6";
        globbing = "fg=#F8F8F2";
        history-expansion = "fg=#BD93F9";
        back-quoted-argument-unclosed = "fg=#FF5555";
        redirection = "fg=#F8F8F2";
        arg0 = "fg=#F8F8F2";
        default = "fg=#F8F8F2";
        cursor = "standout";
      };
    };
    autosuggestion.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      palette = "dracula";

      aws.style = "bold orange";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      cmd_duration.style = "bold yellow";
      directory.style = "bold blue";
      git_branch.style = "bold cyan";
      git_status.style = "bold yellow";
      hostname.style = "bold pink";
      username.style_user = "bold pink";

      custom.worktree = {
        command = "git rev-parse --git-dir 2>/dev/null | sed 's|.*/worktrees/||'";
        when = "git rev-parse --git-dir 2>/dev/null | grep -q /worktrees/";
        format = "[⎇ $output]($style) ";
        style = "bold orange";
      };

      palettes.dracula = {
        background = "#282a36";
        current_line = "#44475a";
        foreground = "#f8f8f2";
        comment = "#6272a4";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
      };
    };
  };
  programs.zoxide.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      "bg" = "#282a36";
      "bg+" = "#44475a";
      "fg" = "#f8f8f2";
      "fg+" = "#f8f8f2";
      "hl" = "#8be9fd";
      "hl+" = "#8be9fd";
      "header" = "#8be9fd";
      "info" = "#bd93f9";
      "marker" = "#ffb86c";
      "pointer" = "#ffb86c";
      "prompt" = "#bd93f9";
      "spinner" = "#ffb86c";
    };
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
