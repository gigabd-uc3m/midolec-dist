# Midolec Distribution

This repository contains Midolec executable builds, runtime assets,
configuration files, provisioning scripts, examples, and user documentation.

## Current Status

The Spanish analysis backend can be configured to use FreeLing and custom NLP
functions.

The English backend currently uses spaCy.

## Supported Environments

The current `midolec-v6` package is a Linux build. Use one of these
environments:

- Ubuntu or another compatible Linux distribution.
- WSL Ubuntu on Windows.
- MobaXterm only as an SSH client connected to a Linux server.

Do not run the package from the local MobaXterm/Cygwin/MSYS/Git Bash shell on
Windows. Those environments are not Ubuntu/WSL, even if some Linux-like
commands appear to work.

## Quick Start

Clone the repository and enter the packaged V6 folder:

```bash
git clone https://github.com/gigabd-uc3m/midolec-dist.git
cd midolec-dist/midolec-v6
```

If you download the ZIP on Windows, open WSL Ubuntu and unzip/copy the package
inside the Linux home directory, for example `~/midolec-dist`.

Run the guided installer:

```bash
bash runtime/provisioning/install_midolec_runtime.sh
```

The installer asks which backend you want to prepare:

```text
1) FreeLing (Spanish backend)
2) spaCy (English backend)
3) Both FreeLing and spaCy
```

It then prints a checklist, explains what is missing, asks for confirmation,
installs the required runtime pieces, and prints a final summary.

## Doctor Check

If you only want to inspect the environment without installing anything, run:

```bash
bash runtime/provisioning/doctor.sh --backend all
```

You can also check only one backend:

```bash
bash runtime/provisioning/doctor.sh --backend freeling
bash runtime/provisioning/doctor.sh --backend spacy
```

## Non-Interactive Install

For scripted setup:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling --yes
bash runtime/provisioning/install_midolec_runtime.sh --backend spacy --yes
bash runtime/provisioning/install_midolec_runtime.sh --backend all --yes
```

## Execution

Show the help message:

```bash
./midolec-v6 -H
```

Run a Spanish example:

```bash
./midolec-v6 examples/es/legal_cross_references.txt examples/es/legal_cross_references.json
```

Run an English example:

```bash
./midolec-v6 -L en examples/en/plain_language_terms.txt examples/en/plain_language_terms.json
```

Generated JSON files under `examples/` are ignored by Git.

## Troubleshooting

If installation fails, copy the full terminal output and send it to:

```text
gigabd@uc3m.es
```

Use this subject prefix:

```text
[midolec-dist] [install]
```

For known errors and manual commands, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Repository Layout

```text
midolec-v6/              Current packaged Midolec V6 executable workspace.
midolec-v6/config/       Language-specific TOML configuration files.
midolec-v6/examples/     Small input texts for quick execution checks.
midolec-v6/runtime/      Runtime documentation and provisioning scripts.
docs/                    User and maintainer documentation.
releases/                Notes about release packaging.
```

## Additional Documentation

- [docs/GUIA_EJECUCION.md](docs/GUIA_EJECUCION.md)
- [docs/DEPENDENCIAS_RUNTIME.md](docs/DEPENDENCIAS_RUNTIME.md)
- [docs/VALIDACION_V6.md](docs/VALIDACION_V6.md)
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [SECURITY.md](SECURITY.md)
