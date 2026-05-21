# Midolec V6 Package Folder

This folder contains the runnable Midolec V6 Linux package. In normal use, open
a terminal here and run `./midolec-v6`.

## Folder Structure

```text
midolec-v6/
├── midolec-v6          Main executable.
├── midolecConfig.toml  Global runtime configuration.
├── config/             Language-specific configuration files.
├── runtime/            Runtime assets and installation scripts.
├── _internal/          PyInstaller internal runtime files.
└── temp/               Temporary working folder.
```

The example input texts are stored one level above this folder:

```text
../examples/
```

## What Users Can Edit

`midolecConfig.toml` controls global options such as the default language and
default context. For Spanish:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

For English:

```toml
[general]
default_language = "en"
default_context = "default_en"
```

The `config/` folder contains language-specific TOML files. Advanced users can
inspect them to understand backend settings, but most users should only change
`midolecConfig.toml`.

## What Users Should Not Edit

Do not modify `_internal/`. It is the embedded PyInstaller runtime used by the
binary. If files are removed or changed there, Midolec may fail before starting
with Python runtime errors.

Do not manually edit files installed under `runtime/freeling/` or
`runtime/spacy/`. Use the provisioning scripts instead:

```bash
bash runtime/provisioning/install_midolec_runtime.sh
```

## Basic Commands

Show help:

```bash
./midolec-v6 -H
```

Run the Spanish example:

```bash
./midolec-v6 ../examples/es/legal_cross_references.txt
```

Run the English example:

```bash
./midolec-v6 -L en ../examples/en/plain_language_terms.txt
```

Check installed dependencies:

```bash
bash runtime/provisioning/doctor.sh --backend all
```
