#!/usr/bin/env bash
set -euo pipefail

REPO="${1:?repository argument required (owner/name)}"
DRY_RUN="${DRY_RUN:-false}"

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "GH_TOKEN is required" >&2
  exit 1
fi

DEPRECATED_LABELS=(
  epic
  work-item
  bug
  documentation
  duplicate
  enhancement
  "good first issue"
  "help wanted"
  invalid
  question
  wontfix
)

remove_label_from_items() {
  local item_type="$1"
  local label="$2"

  local numbers
  numbers="$(gh "$item_type" list \
    --repo "$REPO" \
    --label "$label" \
    --state all \
    --limit 500 \
    --json number \
    --jq '.[].number' 2>/dev/null || true)"

  if [[ -z "$numbers" ]]; then
    return 0
  fi

  while read -r number; do
    [[ -z "$number" ]] && continue
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "DRY RUN: would remove label '$label' from $REPO $item_type #$number"
    else
      echo "Removing label '$label' from $REPO $item_type #$number"
      gh "$item_type" edit "$number" --repo "$REPO" --remove-label "$label"
    fi
  done <<< "$numbers"
}

echo "Cleaning deprecated labels in $REPO (dry_run=$DRY_RUN)"

for label in "${DEPRECATED_LABELS[@]}"; do
  remove_label_from_items issue "$label"
  remove_label_from_items pr "$label"
done

echo "Done: $REPO"
