# Configuration Guide

Midolec V6 uses TOML configuration files. Most users only need to edit
`midolec-v6/midolecConfig.toml`.

## Global Configuration

The global configuration file is:

```text
midolec-v6/midolecConfig.toml
```

It controls cross-language defaults, including:

- Default language.
- Default context.
- Output blocks.
- Shared analysis flags.
- Runtime paths.

To edit it from the terminal:

```bash
cd midolec-v6
nano midolecConfig.toml
```

## Language Configuration

Language-specific configuration files live in:

```text
midolec-v6/config/es.toml
midolec-v6/config/en.toml
```

These files declare backend-specific defaults such as FreeLing for Spanish and
spaCy for English. Most users should not need to edit them.

## Switching The Default Language

For Spanish:

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

You can also override the language for a single command with `-L`:

```bash
./midolec-v6 -L en ../examples/en/plain_language_terms.txt
./midolec-v6 -L es ../examples/es/legal_cross_references.txt
```

## General Rule

Keep source-code changes in the canonical `midolec` repository. Use this
distribution repository for packaged executables, runtime assets, examples,
installation scripts, and user-facing documentation.

## Recommendation For Testers

When testing Midolec, prefer command-line overrides such as `-L en` before
editing configuration files. This makes it easier to return to a known working
state.
