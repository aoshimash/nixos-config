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

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # nix-index is enabled via nix-index-database in flake.nix
  programs.nix-index-database.comma.enable = true;
}
