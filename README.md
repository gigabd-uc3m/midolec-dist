# Midolec Distribution

This repository contains packaged Midolec workspaces, runtime helpers,
configuration files, examples, release notes, and user-facing documentation.

The canonical source-code repository is `gigabd-uc3m/midolec`. This repository
is only for distribution packages and release-oriented documentation.

## Available Packages

| Package | Status | Recommended Use |
| --- | --- | --- |
| `midolec-v6/` | Stable internal package | Regular execution, validation, collaborator testing, and TFM documentation. |
| `midolec-v7-a1/` | Partial alpha build | Preview of V7 output features, especially Markdown reports and structured Findings. |

Use `midolec-v6/` when you need the most stable package. Use `midolec-v7-a1/`
only when you explicitly want to test V7 alpha behavior.

## Supported Environments

The current packages are Linux builds. Use one of these environments:

- Ubuntu or another compatible Linux distribution.
- WSL Ubuntu on Windows.
- MobaXterm only as an SSH client connected to a Linux server.

Do not run the packages from the local MobaXterm/Cygwin/MSYS/Git Bash shell on
Windows. Those environments are not Ubuntu/WSL, even if some Linux-like
commands appear to work.

## Quick Start

Clone the repository:

```bash
git clone https://github.com/gigabd-uc3m/midolec-dist.git
cd midolec-dist
```

For the stable V6 package:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh
./midolec-v6 -H
./midolec-v6 ../examples/v6/es/legal_cross_references.txt
```

For the V7 alpha package:

```bash
cd midolec-v7-a1
./midolec-v7-a1 -H
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

V7-a1 is a partial alpha build. It is intended to test new output behavior and
should not be treated as a drop-in replacement for V6.

## Repository Layout

```text
midolec-v6/              Stable V6 packaged executable workspace.
midolec-v7-a1/           Partial V7 alpha workspace and documentation.
examples/v6/             V6 example input texts.
examples/v7-a1/          V7-a1 example input texts.
docs/                    Repository-level distribution documentation.
releases/                Release packaging policy notes.
```

## Documentation Map

Global documentation:

- [docs/README.md](docs/README.md): documentation index.
- [docs/VERSION_MATRIX.md](docs/VERSION_MATRIX.md): package status and version comparison.
- [docs/RELEASES.md](docs/RELEASES.md): release packaging policy.
- [docs/REPORTING_UNKNOWN_ERRORS.md](docs/REPORTING_UNKNOWN_ERRORS.md): where to report unknown errors.
- [CONTRIBUTING.md](CONTRIBUTING.md): contribution rules, commit labels, and pull request workflow.
- [SECURITY.md](SECURITY.md): supported versions and vulnerability reporting process.

Version-specific documentation:

- [midolec-v6/README.md](midolec-v6/README.md): V6 package map and safe-editing notes.
- [midolec-v6/docs/00_EXECUTION_GUIDE.md](midolec-v6/docs/00_EXECUTION_GUIDE.md): V6 execution guide.
- [midolec-v7-a1/README.md](midolec-v7-a1/README.md): V7-a1 alpha package notes.
- [midolec-v7-a1/docs/00_EXECUTION_GUIDE.md](midolec-v7-a1/docs/00_EXECUTION_GUIDE.md): V7-a1 execution guide.

## Troubleshooting

If installation or execution fails, copy the full terminal output and send it to:

[gigabd@uc3m.es](mailto:gigabd@uc3m.es?subject=%5Bmidolec-dist%5D%5Binstall%5D)

Use this subject prefix:

```text
[midolec-dist] [install]
```

Before reporting, run the package-specific dependency check when available:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend all
```

For V7-a1 FreeLing runtime diagnostics:

```bash
cd midolec-v7-a1
bash runtime/provisioning/freeling/check_runtime.sh
```
