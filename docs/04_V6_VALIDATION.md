# Midolec V6 Validation

This document describes the validation scope for the Midolec V6 distribution
package.

## Goal

Validation should confirm that:

- The binary starts and shows help.
- The Spanish FreeLing backend can run without manually exporting
  `LD_LIBRARY_PATH`.
- The English spaCy backend can run after provisioning.
- The runtime provisioning scripts install and check the required assets.
- Example inputs generate valid JSON outputs.

## Tested Environment

The current package is intended for:

- Ubuntu or compatible Linux distributions.
- WSL Ubuntu on Windows.
- Linux servers accessed directly or through SSH.

Local MobaXterm/Cygwin/MSYS/Git Bash shells are not supported execution
environments for this Linux package.

## Runtime Preparation

Recommended preparation:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh
```

Read-only dependency check:

```bash
bash runtime/provisioning/doctor.sh --backend all
```

## Minimal Binary Check

From `midolec-v6/`:

```bash
./midolec-v6 -H
```

Expected result: the command prints the Midolec CLI help and exits normally.

## Spanish Smoke Test

```bash
./midolec-v6 ../examples/es/legal_cross_references.txt
test -f ../examples/es/legal_cross_references.json
```

Expected result: a JSON file is created next to the input text.

## English Smoke Test

```bash
./midolec-v6 -L en ../examples/en/plain_language_terms.txt
test -f ../examples/en/plain_language_terms.json
```

Expected result: a JSON file is created next to the input text.

## Configuration Test

Edit `midolecConfig.toml` and switch the default language:

```toml
[general]
default_language = "en"
default_context = "default_en"
```

Run an English text without `-L en` and confirm that the English backend is
used. Restore Spanish defaults afterwards:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

## Validation Criteria

A V6 distribution package is considered ready when:

- `./midolec-v6 -H` works.
- `doctor.sh --backend all` reports the expected checks.
- Spanish and English example commands generate JSON outputs.
- FreeLing dependencies resolve through the package runtime layout.
- No manual `LD_LIBRARY_PATH` export is needed for normal Spanish execution.
- `_internal/base_library.zip` is present.

## Known Issues Found During Previous Validation

Previous validation rounds identified these packaging risks:

- Missing `_internal/base_library.zip` prevents PyInstaller from loading Python
  encodings.
- Running from local MobaXterm shells can mimic Linux commands while still not
  being a supported Ubuntu/WSL runtime.
- Missing Ubuntu system libraries, such as `libboost_program_options`, can make
  FreeLing checks fail even when runtime assets are present.
- Incorrect spaCy model copy layout can prevent the English loader from using
  the bundled model.

These issues are now documented in `03_TROUBLESHOOTING.md`.

## Final State

The current validation strategy is based on:

- Guided provisioning.
- Read-only dependency checks.
- Spanish and English smoke tests.
- Documentation that explains what information to report for unknown errors.
