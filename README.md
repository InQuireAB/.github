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

## Label synchronization

To sync labels across listed repositories:

1. Ensure repository secret `ORG_LABEL_SYNC_TOKEN` exists in this repository.
2. Run the **Sync repository labels** workflow manually, or push changes to `.github/labels.yml`.
3. Keep Organization **Repository labels** defaults aligned for new repositories.
