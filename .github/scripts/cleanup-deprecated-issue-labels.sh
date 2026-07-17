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

delete_label_definition() {
  local label="$1"

  if ! gh label list --repo "$REPO" --limit 200 --json name --jq '.[].name' | grep -Fxq "$label"; then
    echo "Label '$label' not present in $REPO (skipped)"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN: would delete label '$label' from $REPO"
    return 0
  fi

  echo "Deleting label '$label' from $REPO"
  gh label delete "$label" --repo "$REPO" --yes
}

echo "Deleting deprecated label definitions in $REPO (dry_run=$DRY_RUN)"

for label in "${DEPRECATED_LABELS[@]}"; do
  delete_label_definition "$label"
done

echo "Done: $REPO"
