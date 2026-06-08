# V7-a1 Validation

This document defines the minimum validation expected before presenting or
sharing the V7-a1 partial alpha package.

## Minimum Checks

Run from `midolec-v7-a1/` after the binary exists:

```bash
./midolec-v7-a1 -H
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

Expected result:

- the help command starts normally;
- the example command generates a JSON output;
- if Markdown reports are enabled, a `.md` report is generated;
- generated `.json` and `.md` files are ignored by Git.

## Output Checks

Open the generated JSON and confirm:

- `_schema_version` is present when V7 output fields are enabled;
- `Findings` is present when `show_findings = true`;
- `Suggestion_Set` is hidden when `show_suggestion_set = false`;
- `char_span` fields are present when `show_spans = true`.

## Alpha Limitations

V7-a1 is not expected to have the same validation guarantees as V6. Record any
missing dependency checks, unsupported backends, or incomplete runtime behavior
in the release notes before sharing the package.
