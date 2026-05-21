# Releases

This document describes how Midolec distribution releases should be prepared and
documented.

For execution instructions, see `docs/00_EXECUTION_GUIDE.md`. For validation,
see `docs/04_V6_VALIDATION.md`.

## Version Convention

Use explicit version folders and release notes whenever possible. A release
should make clear:

- Which Midolec version is distributed.
- Which operating system/runtime is supported.
- Which runtime assets are included or expected to be downloaded.
- Which validation checks were run.

Recommended labels:

```text
v6-runtime-YYYY-MM-DD
v6-binary-YYYY-MM-DD
```

## Recommended Assets

A V6 release may include:

- The packaged `midolec-v6/` binary folder.
- FreeLing runtime libraries, when licensing and storage policy allow it.
- FreeLing linguistic resources, when licensing and storage policy allow it.
- spaCy model assets, when appropriate.
- Validation logs or release notes.

Large runtime assets should be distributed as release assets rather than source
files whenever they are too heavy for Git.

## Current Internal V6 Delivery

The current V6 distribution is an internal Linux package with:

- A PyInstaller executable.
- Editable configuration files.
- Runtime provisioning scripts.
- FreeLing and spaCy setup helpers.
- Example input texts.
- Documentation for installation, troubleshooting, and validation.

The current FreeLing strategy is to patch `_pyfreeling.so` and native libraries
so dependencies resolve from `runtime/freeling/lib/` through RPATH/RUNPATH.
Users should not need to export `LD_LIBRARY_PATH` manually.

## New V6 Release Checklist

Before publishing or replacing a V6 package:

1. Build the binary from the canonical `midolec` source repository.
2. Copy or provision runtime assets.
3. Ensure `_internal/base_library.zip` is present.
4. Run `./midolec-v6 -H`.
5. Run `bash runtime/provisioning/doctor.sh --backend all`.
6. Run the Spanish and English example commands.
7. Confirm generated JSON files are ignored by Git.
8. Review `README.md`, `midolec-v6/README.md`, and `docs/`.
9. Update release notes with known limitations.

## Known Limitations

- The package targets Linux/Ubuntu-compatible environments.
- Windows users should use WSL Ubuntu rather than local MobaXterm/Cygwin/MSYS
  shells.
- FreeLing and spaCy runtime assets can be large and should be handled through
  release assets or provisioning scripts.
- Public release of third-party assets should be reviewed for licensing.

## Future Public Release

Before publishing a wider public release:

- Review third-party licenses.
- Confirm runtime asset hosting policy.
- Re-run validation on a clean Ubuntu or WSL Ubuntu environment.
- Confirm that unknown-error reporting instructions are easy for non-technical
  users to follow.
