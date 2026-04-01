{ pkgs, ... }:
let
  git-delete-merged-branches = pkgs.writeShellScriptBin "git-delete-merged-branches" ''
    set -euo pipefail

    for arg in "$@"; do
      case "$arg" in
        -h|--help)
          echo "Usage: git delete-merged-branches [-h|--help]"
          echo ""
          echo "Delete local branches that have been merged into the default branch,"
          echo "along with their associated worktrees."
          echo "Shows a list of targets and asks for confirmation before deleting."
          exit 0
          ;;
        *)
          echo "Unknown option: $arg" >&2
          exit 1
          ;;
      esac
    done

    # Detect default branch
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||') \
      || DEFAULT_BRANCH="main"

    # Collect merged branches (excluding the default branch itself)
    MERGED_BRANCHES=()
    while IFS= read -r branch; do
      branch=$(echo "$branch" | sed 's/^[+* ]*//' | xargs)
      [ -z "$branch" ] && continue
      [ "$branch" = "$DEFAULT_BRANCH" ] && continue
      MERGED_BRANCHES+=("$branch")
    done < <(git branch --merged "$DEFAULT_BRANCH")

    if [ ''${#MERGED_BRANCHES[@]} -eq 0 ]; then
      echo "No merged branches found."
      exit 0
    fi

    # Build worktree lookup: branch -> worktree path
    declare -A WORKTREE_MAP
    while IFS= read -r line; do
      wt_path=$(echo "$line" | awk '{print $1}')
      wt_branch=$(echo "$line" | grep -oP '\[.*?\]' | tr -d '[]')
      [ -n "$wt_branch" ] && WORKTREE_MAP["$wt_branch"]="$wt_path"
    done < <(git worktree list)

    # Show targets
    echo "Default branch: $DEFAULT_BRANCH"
    echo ""
    echo "The following will be deleted:"
    echo ""

    WORKTREES_TO_REMOVE=()
    for branch in "''${MERGED_BRANCHES[@]}"; do
      wt="''${WORKTREE_MAP[$branch]:-}"
      if [ -n "$wt" ]; then
        echo "  branch: $branch"
        echo "    worktree: $wt"
        WORKTREES_TO_REMOVE+=("$wt")
      else
        echo "  branch: $branch"
      fi
    done

    echo ""
    echo "Total: ''${#MERGED_BRANCHES[@]} branches, ''${#WORKTREES_TO_REMOVE[@]} worktrees"
    echo ""

    read -rp "Proceed? [y/N] " answer
    case "$answer" in
      [yY]) ;;
      *)
        echo "Aborted."
        exit 0
        ;;
    esac

    echo ""

    # Remove worktrees first
    for wt in "''${WORKTREES_TO_REMOVE[@]}"; do
      echo "  Removing worktree: $wt"
      git worktree remove --force "$wt"
    done

    # Then delete branches
    for branch in "''${MERGED_BRANCHES[@]}"; do
      echo "  Deleting branch: $branch"
      git branch -d "$branch"
    done

    # Prune worktree metadata
    git worktree prune

    echo ""
    echo "Done. Deleted ''${#MERGED_BRANCHES[@]} branches and ''${#WORKTREES_TO_REMOVE[@]} worktrees."
  '';
in
{
  catppuccin.zsh-syntax-highlighting.enable = true;
  catppuccin.starship.enable = true;
  catppuccin.fzf.enable = true;

  home.packages = [
    pkgs.zsh-completions
    pkgs.semgrep
    pkgs.tig
    pkgs.lsof
    git-delete-merged-branches
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
