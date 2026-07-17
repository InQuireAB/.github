# InQuireAB GitHub Defaults

This repository is the canonical home for shared GitHub standards across InQuireAB repositories.

## What lives here

- `.github/ISSUE_TEMPLATE/*`: default issue forms inherited by repositories that do not define local issue templates
- `.github/pull_request_template.md`: default pull request template
- `.github/labels.yml`: canonical label contract
- `.github/repos-label-sync.txt`: target repositories for label synchronization
- `.github/workflows/sync-labels.yml`: workflow that applies labels from `labels.yml` to each target repository

## Operating model

- Shared standards live in this repository.
- Product repositories keep repo-specific automation such as CI or release workflows.
- Product repositories should not duplicate issue templates unless there is a documented exception.

## Naming conventions

Issue Types handle primary classification. Labels cover only subtypes and ceremony markers.

| Layer | Format | Examples |
|---|---|---|
| GitHub Issue Type (org setting) | Title Case | `Epic`, `Work Item`, `Bug` |
| Issue title prefix | Title Case | `[Epic]:`, `[Work Item][Feature]:`, `[Bug]:` |
| Label slug | kebab-case | `feature`, `task`, `sprint-meta`, `internal`, `chore` |
| Template filename | kebab-case | `work-item-feature.yml`, `work-item-task.yml` |

Filter by Issue Type for primary classification (`type:"Work Item"`, `type:Epic`, `type:Bug`). Use labels only for Work Item subtypes (`label:feature`, `label:task`) or ceremony issues (`label:sprint-meta`).

`Feature` and `Task` are **not** org Issue Types. They are Work Item subtypes expressed through labels (`feature`, `task`) and title prefixes (`[Feature]`, `[Task]`). Both `work-item-feature.yml` and `work-item-task.yml` create issues with type `Work Item`.

## Label synchronization

To sync labels across listed repositories:

1. Ensure repository secret `ORG_LABEL_SYNC_TOKEN` exists in this repository.
2. Run the **Sync repository labels** workflow manually, or push changes to `.github/labels.yml`.
3. Keep Organization **Repository labels** defaults aligned for new repositories.
