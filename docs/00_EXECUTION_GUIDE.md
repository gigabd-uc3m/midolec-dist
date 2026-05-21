# Execution Guide

This guide explains how to install the runtime dependencies and run the Midolec
V6 binary package.

## Quick Execution Flow

1. Use Ubuntu, WSL Ubuntu, or an SSH session connected to a Linux server.
2. Open a terminal in the `midolec-v6/` folder.
3. Run the guided runtime installer.
4. Process one of the example text files.
5. Open the generated JSON result.

Do not run this Linux package from local MobaXterm/Cygwin/MSYS/Git Bash shells
on Windows. If you are on Windows, use WSL Ubuntu.

## Recommended Guided Installation

The recommended workflow for non-technical users is the guided installer. It
asks whether to install FreeLing, spaCy, or both, shows a dependency checklist,
asks for confirmation, and prints a final summary.

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh
```

To inspect the environment without installing anything:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend all
```

Direct installation commands for maintainers and scripted environments are
documented in `docs/01_RUNTIME_DEPENDENCIES.md`.

## Spanish With FreeLing

The Spanish backend uses FreeLing. It requires native libraries and linguistic
resources under `runtime/freeling/`. The guided installer downloads and checks
these assets.

If the guided installer reports an error, run:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend freeling
```

## English With spaCy

The English backend uses spaCy, pyphen, and the `en_core_web_sm` model. The
guided installer prepares these dependencies when spaCy is selected.

If the guided installer reports an error, run:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend spacy
```

## Running Midolec

All commands in this section are executed from the `midolec-v6/` folder:

```bash
cd ~/midolec-dist/midolec-v6
```

Check that the binary starts:

```bash
./midolec-v6 -H
```

### 1. Spanish Example

Spanish is the default language. The default language is configured in
`midolecConfig.toml`:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

Process a Spanish example. Midolec automatically creates
`../examples/es/legal_cross_references.json`:

```bash
./midolec-v6 ../examples/es/legal_cross_references.txt
```

Open the generated JSON file with `nano`:

```bash
nano ../examples/es/legal_cross_references.json
```

Or with `vim`:

```bash
vim ../examples/es/legal_cross_references.json
```

### 2. English Example

To use English only for one command, pass `-L en`:

```bash
./midolec-v6 -L en ../examples/en/plain_language_terms.txt
```

To make English the default language, open `midolecConfig.toml`:

```bash
nano midolecConfig.toml
```

Set these values:

```toml
[general]
default_language = "en"
default_context = "default_en"
```

Open the generated JSON file:

```bash
nano ../examples/en/plain_language_terms.json
```

To switch back to Spanish, restore:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

## Running Your Own Text

To process your own file and choose the output path:

```bash
./midolec-v6 my_text.txt my_result.json
```

If you do not provide an output path, Midolec creates a `.json` file next to the
input file. You can also open the `examples/` folder with a graphical file
explorer and double-click the generated `.json` file.
