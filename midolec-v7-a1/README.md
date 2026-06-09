# Midolec V7-a1 Package Folder

This folder is reserved for the Midolec V7-a1 partial alpha distribution
package.

V7-a1 is not the stable replacement for V6. Use it to test V7 output features,
especially Markdown reports and the structured Findings-oriented JSON contract.
For normal collaborator execution, prefer `../midolec-v6/`.

## Expected Folder Structure

```text
midolec-v7-a1/
├── midolec-v7-a1      Main executable, added after the V7-a1 binary rebuild.
├── midolecConfig.toml Global runtime configuration.
├── config/            Language-specific configuration files.
├── runtime/           Runtime notes and provisioning scripts.
├── docs/              V7-a1 package documentation.
└── _internal/         PyInstaller internal runtime files, added by the build.
```

## Current Alpha Status

This folder currently contains the V7-a1 executable, `_internal/`, configuration
files, runtime helper scripts, and documentation. External runtime assets such
as FreeLing resources and spaCy models are still installed through provisioning
scripts and are not committed to Git.

Do not copy `v7/run_midolec_v6.sh` into this package. It is not part of the
V7-a1 distribution contract.

## Basic Commands

```bash
./midolec-v7-a1 -H
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

When Markdown report generation is enabled, V7-a1 may generate both:

```text
sample_es.json
sample_es.md
```

Generated JSON and Markdown report files are ignored by Git.

## V7-a1 Documentation

- [docs/00_EXECUTION_GUIDE.md](docs/00_EXECUTION_GUIDE.md): alpha execution guide.
- [docs/01_CONFIGURATION_GUIDE.md](docs/01_CONFIGURATION_GUIDE.md): language, context, and output configuration.
- [docs/02_MARKDOWN_REPORT.md](docs/02_MARKDOWN_REPORT.md): Markdown report behavior.
- [docs/03_FINDINGS_JSON.md](docs/03_FINDINGS_JSON.md): V7 Findings JSON summary.
- [docs/04_TROUBLESHOOTING.md](docs/04_TROUBLESHOOTING.md): alpha troubleshooting.
- [docs/05_VALIDATION.md](docs/05_VALIDATION.md): alpha validation checklist.
- [docs/06_REPORTING_UNKNOWN_ERRORS.md](docs/06_REPORTING_UNKNOWN_ERRORS.md): unknown-error report template.
