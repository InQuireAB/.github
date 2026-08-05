#!/usr/bin/env bash
set -euo pipefail

# Upsert canonical labels from .github/labels.yml into target repositories.
# Does not delete unknown labels. Does not apply labels to issues.
#
# Usage:
#   DRY_RUN=true  ./scripts/sync-labels.sh                 # preview all allowlisted repos
#   DRY_RUN=false ./scripts/sync-labels.sh                 # apply to all allowlisted repos
#   DRY_RUN=false ./scripts/sync-labels.sh InQuireAB/queue-mod
#
# From repo root, with paths relative to this file's location:
#   DRY_RUN=true bash .github/scripts/sync-labels.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LABELS_FILE="${LABELS_FILE:-$ROOT_DIR/.github/labels.yml}"
REPOS_FILE="${REPOS_FILE:-$ROOT_DIR/.github/repos-label-sync.txt}"
DRY_RUN="${DRY_RUN:-true}"
TARGET_REPO="${1:-}"

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "GH_TOKEN is required" >&2
  exit 1
fi

command -v gh >/dev/null || {
  echo "gh CLI is required" >&2
  exit 1
}

command -v yq >/dev/null || {
  echo "yq is required (https://github.com/mikefarah/yq)" >&2
  exit 1
}

if [[ ! -f "$LABELS_FILE" ]]; then
  echo "Labels file not found: $LABELS_FILE" >&2
  exit 1
fi

if [[ -z "$TARGET_REPO" && ! -f "$REPOS_FILE" ]]; then
  echo "Repos file not found: $REPOS_FILE" >&2
  exit 1
fi

normalize_color() {
  local color="$1"
  color="${color#\#}"
  printf '%s' "$color"
}

sync_repo() {
  local repo="$1"

  echo
  echo "Syncing labels to $repo (dry_run=$DRY_RUN)"

  while IFS=$'\t' read -r name color description; do
    [[ -z "$name" ]] && continue
    color="$(normalize_color "$color")"

    if [[ "$DRY_RUN" == "true" ]]; then
      printf 'DRY RUN: gh label create %q --repo %q --color %q --description %q --force\n' \
        "$name" "$repo" "$color" "$description"
    else
      gh label create "$name" \
        --repo "$repo" \
        --color "$color" \
        --description "$description" \
        --force
    fi
  done < <(
    yq -r '.labels[] | [.name, .color, (.description // "")] | @tsv' \
      "$LABELS_FILE"
  )
}

if [[ -n "$TARGET_REPO" ]]; then
  sync_repo "$TARGET_REPO"
else
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    [[ "$repo" =~ ^[[:space:]]*# ]] && continue
    sync_repo "$repo"
  done < "$REPOS_FILE"
fi

echo
echo "Label sync complete. dry_run=$DRY_RUN"