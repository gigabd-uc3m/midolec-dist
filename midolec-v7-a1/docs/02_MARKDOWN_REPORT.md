# V7-a1 Markdown Report

V7-a1 can generate an optional Markdown report beside the canonical JSON
output.

The JSON remains the source of truth for automated tools, tests, and
integrations. The Markdown file is a derived reading view for people.

## Enable The Report

In `midolecConfig.toml`:

```toml
[output]
generate_markdown_report = true
markdown_report_language = "en"
markdown_report_word_table = "findings_only"
markdown_report_show_technical_appendix = false
markdown_report_collapse_clean_paragraphs = true
```

## Expected Output

If Midolec writes:

```text
sample_es.json
```

it may also write:

```text
sample_es.md
```

The Markdown report may include:

- an executive summary;
- readability-oriented sections;
- priority findings;
- paragraph and sentence analysis;
- optional technical details.

## Git Hygiene

Generated Markdown reports are ignored by Git. Commit only source `.txt`
examples or documentation files, not generated `.md` reports.
