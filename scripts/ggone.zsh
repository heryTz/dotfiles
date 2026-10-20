ggone() {
  if [[ "$1" != "--no-fetch" ]]; then
    git fetch --prune --quiet || return 1
  fi

  local current_branch worktree_branches branch track answer
  local -a deletable skipped
  current_branch=$(git symbolic-ref --quiet --short HEAD)
  worktree_branches=$(git worktree list --porcelain | sed -n 's|^branch refs/heads/||p')

  while IFS=$'\t' read -r branch track; do
    [[ "$track" == "[gone]" ]] || continue
    if [[ "$branch" == "$current_branch" ]]; then
      skipped+=("$branch (checked out)")
    elif grep -qxF "$branch" <<<"$worktree_branches"; then
      skipped+=("$branch (used by a worktree)")
    else
      deletable+=("$branch")
    fi
  done < <(git for-each-ref --format='%(refname:short)%09%(upstream:track)' refs/heads)

  if (( ${#skipped} )); then
    echo "Skipped:"
    printf '  %s\n' "${skipped[@]}"
    echo
  fi

  if (( ${#deletable} == 0 )); then
    echo "No gone branches to delete."
    return 0
  fi

  echo "Gone branches:"
  for branch in "${deletable[@]}"; do
    printf '  %s  %s\n' "$branch" "$(git log -1 --format='%h %s (%cr)' "$branch")"
  done
  echo

  read -r "answer?Delete these ${#deletable} branches? [y/N] "
  if [[ "$answer" == [Yy] ]]; then
    git branch -D "${deletable[@]}"
  else
    echo "Aborted."
  fi
}
