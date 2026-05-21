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

If you download the ZIP on Windows, open WSL Ubuntu and unzip or copy the
package inside the Linux home directory, for example `~/midolec-dist`.

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

## Execution

All commands below must be executed from the `midolec-v6` folder:

```bash
cd ~/midolec-dist/midolec-v6
```

Show the help message. This only checks that the executable can start:

```bash
./midolec-v6 -H
```

### 1. Spanish Example

Midolec uses Spanish by default. The default language is configured in
`midolecConfig.toml`:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

Run a Spanish example. Midolec creates a JSON file next to the input text, using
the same filename with the `.json` extension:

```bash
./midolec-v6 ../examples/es/legal_cross_references.txt
```

Open the generated Spanish result in the terminal:

```bash
nano ../examples/es/legal_cross_references.json
```

### 2. English Example

To use English for a single command, pass `-L en`:

```bash
./midolec-v6 -L en ../examples/en/plain_language_terms.txt
```

To make English the default language, edit `midolecConfig.toml`:

```bash
nano midolecConfig.toml
```

Set these values:

```toml
[general]
default_language = "en"
default_context = "default_en"
```

Open the generated English result in the terminal:

```bash
nano ../examples/en/plain_language_terms.json
```

To switch back to Spanish, restore:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

If you prefer a graphical workflow, open the `examples/` folder with your file
explorer and double-click the generated `.json` file.

## Check Your Dependencies

If you only want to inspect the environment without installing anything, run:

```bash
bash runtime/provisioning/doctor.sh --backend all
```

You can also check only one backend:

```bash
bash runtime/provisioning/doctor.sh --backend freeling
bash runtime/provisioning/doctor.sh --backend spacy
```

The checker prints `OK`, `MISSING`, and `WARN` lines so you can see what is
ready and what still needs attention.

## Troubleshooting

If installation fails, copy the full terminal output and send it to:

[gigabd@uc3m.es](mailto:gigabd@uc3m.es?subject=%5Bmidolec-dist%5D%5Binstall%5D)

Use this subject prefix:

```text
[midolec-dist] [install]
```

For known errors and manual recovery commands, see
[docs/03_TROUBLESHOOTING.md](docs/03_TROUBLESHOOTING.md).

## Repository Layout

```text
midolec-v6/              Current packaged Midolec V6 executable workspace.
midolec-v6/config/       Language-specific TOML configuration files.
midolec-v6/runtime/      Runtime documentation and provisioning scripts.
examples/                Small input texts for quick execution checks.
docs/                    User and maintainer documentation.
releases/                Notes about release packaging.
```

## Recommended Documentation

- [docs/00_GUIA_EJECUCION.md](docs/00_GUIA_EJECUCION.md): step-by-step execution guide for users.
- [docs/01_DEPENDENCIAS_RUNTIME.md](docs/01_DEPENDENCIAS_RUNTIME.md): runtime dependency details and direct installation commands.
- [docs/02_GUIA_CONFIGURACION.md](docs/02_GUIA_CONFIGURACION.md): configuration files and language options.
- [docs/03_TROUBLESHOOTING.md](docs/03_TROUBLESHOOTING.md): known installation and execution errors.
- [docs/04_VALIDACION_V6.md](docs/04_VALIDACION_V6.md): validation checklist for the V6 package.
- [docs/05_RELEASES.md](docs/05_RELEASES.md): release and packaging notes.
- [midolec-v6/README.md](midolec-v6/README.md): package-folder map and safe-editing notes.
- [CONTRIBUTING.md](CONTRIBUTING.md): contribution rules, commit labels, and pull request workflow.
- [SECURITY.md](SECURITY.md): supported versions and vulnerability reporting process.

## Documentation Index

```text
.
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── docs/
│   ├── 00_GUIA_EJECUCION.md
│   ├── 01_DEPENDENCIAS_RUNTIME.md
│   ├── 02_GUIA_CONFIGURACION.md
│   ├── 03_TROUBLESHOOTING.md
│   ├── 04_VALIDACION_V6.md
│   └── 05_RELEASES.md
├── midolec-v6/
│   ├── README.md
│   ├── runtime/
│   ├── config/
│   └── midolec-v6
├── examples/
│   ├── es/
│   └── en/
└── releases/
```
