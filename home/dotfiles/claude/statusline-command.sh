#!/bin/sh
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | xargs printf '%.0f')
dir=$(basename "$cwd")
# Detect branch handling git worktrees correctly
# git-dir is worktree-specific (e.g. .git/worktrees/<name> for linked worktrees)
_git_dir=$(git -C "$cwd" --no-optional-locks rev-parse --git-dir 2>/dev/null)
if [ -n "$_git_dir" ]; then
  case "$_git_dir" in /*) ;; *) _git_dir="$cwd/$_git_dir" ;; esac
  _head=$(cat "$_git_dir/HEAD" 2>/dev/null)
  case "$_head" in
    "ref: refs/heads/"*) branch="${_head#ref: refs/heads/}" ;;
    *) branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null) ;;
  esac
fi

# Nerd Font: git branch icon (U+E0A0)
branch_icon=$(printf '\xee\x82\xa0')

# colors (Dracula, matching Starship config)
blue=$(printf '\033[1;34m')   # directory (same as Starship directory.style)
cyan=$(printf '\033[1;36m')   # git branch (same as Starship git_branch.style)
yellow=$(printf '\033[1;33m') # git status (same as Starship git_status.style)
green=$(printf '\033[32m')    # ctx < 50%
red=$(printf '\033[31m')      # ctx >= 80%
ctx_yellow=$(printf '\033[33m') # ctx 50-80%
dim=$(printf '\033[2m')
reset=$(printf '\033[0m')

# context color: green < 50%, yellow < 80%, red >= 80%
if [ "$context_pct" -ge 80 ] 2>/dev/null; then
  ctx_color="$red"
elif [ "$context_pct" -ge 50 ] 2>/dev/null; then
  ctx_color="$ctx_yellow"
else
  ctx_color="$green"
fi

if [ -n "$branch" ]; then
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  git_status=""
  [ "$staged" -gt 0 ] && git_status="${git_status}+"
  [ "$modified" -gt 0 ] && git_status="${git_status}!"
  [ "$untracked" -gt 0 ] && git_status="${git_status}?"
  if [ -n "$git_status" ]; then
    printf "${blue}%s${reset} on ${cyan}${branch_icon} %s${reset} ${yellow}[%s]${reset}  ${ctx_color}ctx:%s%%${reset}  ${dim}%s${reset}" \
      "$dir" "$branch" "$git_status" "$context_pct" "$model"
  else
    printf "${blue}%s${reset} on ${cyan}${branch_icon} %s${reset}  ${ctx_color}ctx:%s%%${reset}  ${dim}%s${reset}" \
      "$dir" "$branch" "$context_pct" "$model"
  fi
else
  printf "${blue}%s${reset}  ${ctx_color}ctx:%s%%${reset}  ${dim}%s${reset}" "$dir" "$context_pct" "$model"
fi
