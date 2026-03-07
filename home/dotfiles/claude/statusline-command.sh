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

# colors
green=$(printf '\033[32m')
yellow=$(printf '\033[33m')
red=$(printf '\033[31m')
cyan=$(printf '\033[36m')
dim=$(printf '\033[2m')
reset=$(printf '\033[0m')

# context color: green < 50%, yellow < 80%, red >= 80%
if [ "$context_pct" -ge 80 ] 2>/dev/null; then
  ctx_color="$red"
elif [ "$context_pct" -ge 50 ] 2>/dev/null; then
  ctx_color="$yellow"
else
  ctx_color="$green"
fi

if [ -n "$branch" ]; then
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  git_status=""
  [ "$staged" -gt 0 ] && git_status="${green}+${staged}${reset}"
  [ "$modified" -gt 0 ] && git_status="${git_status} ${yellow}~${modified}${reset}"
  [ "$untracked" -gt 0 ] && git_status="${git_status} ${red}?${untracked}${reset}"
  git_info="${cyan}${branch}${reset}"
  [ -n "$git_status" ] && git_info="$git_info $git_status"
  printf "${dim}%s${reset}  %s  ${ctx_color}ctx:%s%%${reset}  ${dim}%s${reset}" "$dir" "$git_info" "$context_pct" "$model"
else
  printf "${dim}%s${reset}  ${ctx_color}ctx:%s%%${reset}  ${dim}%s${reset}" "$dir" "$context_pct" "$model"
fi
