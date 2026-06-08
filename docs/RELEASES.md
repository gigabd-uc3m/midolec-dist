# Release Packaging Policy

This document describes repository-level release rules for Midolec distribution
packages. Version-specific validation and checklist documents live inside each
package folder.

## Version Folders

Use explicit version folders:

```text
midolec-v6/
midolec-v7-a1/
```

Each package folder should make clear:

- which Midolec version is distributed;
- which executable name should be used;
- whether the package is stable, preview, alpha, or deprecated;
- which operating system/runtime is supported;
- which runtime assets are included or expected to be downloaded;
- which validation checks were run.

## Release Labels

Recommended labels:

```text
v6-binary-YYYY-MM-DD
v6-runtime-YYYY-MM-DD
v7-a1-alpha-YYYY-MM-DD
v7-a1-markdown-preview-YYYY-MM-DD
```

## Asset Policy

Large runtime assets should be published as GitHub Release assets or installed
through provisioning scripts. Do not store heavy third-party runtime dumps in
Git unless the team has explicitly approved that distribution strategy.

Avoid committing:

- FreeLing native library dumps;
- FreeLing linguistic resource dumps;
- downloaded spaCy models;
- generated JSON outputs;
- generated Markdown reports;
- local logs, caches, temporary files, and environment files.

## Package-Specific Checklists

- V6 release checklist: [../midolec-v6/docs/05_RELEASE_CHECKLIST.md](../midolec-v6/docs/05_RELEASE_CHECKLIST.md)
- V7-a1 validation notes: [../midolec-v7-a1/docs/05_VALIDATION.md](../midolec-v7-a1/docs/05_VALIDATION.md)

## Before Publishing A Wider Release

- Review third-party licenses.
- Confirm runtime asset hosting policy.
- Re-run validation on a clean Ubuntu or WSL Ubuntu environment.
- Confirm that unknown-error reporting instructions are clear for non-technical users.
- Confirm generated outputs are ignored by Git.
