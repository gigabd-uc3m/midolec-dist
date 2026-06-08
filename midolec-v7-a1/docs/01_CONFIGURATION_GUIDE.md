# V7-a1 Configuration Guide

Midolec V7-a1 uses TOML configuration files. Most users should start with:

```text
midolec-v7-a1/midolecConfig.toml
```

Language-specific files live in:

```text
midolec-v7-a1/config/es.toml
midolec-v7-a1/config/en.toml
```

## Language And Context

The global configuration controls the default language and context:

```toml
[general]
default_language = "es"
default_context = "default_es"
```

The command line may override the language for a single execution:

```bash
./midolec-v7-a1 -L en ../examples/v7-a1/sample_en.txt
```

## Output Configuration

V7-a1 adds output controls for the new JSON contract and the optional Markdown
report:

```toml
[output]
show_findings = true
show_structure_ids = true
show_spans = true
show_suggestion_set = false
generate_markdown_report = true
markdown_report_language = "en"
markdown_report_word_table = "findings_only"
```

`Findings` is the preferred V7 machine-readable layer. `Suggestion_Set` may
exist for migration or debugging, but it should not be treated as the primary
V7 contract.

## Recommendation

For alpha testing, keep a copy of the original `midolecConfig.toml` before
making local changes. This makes it easier to return to a known working state.
