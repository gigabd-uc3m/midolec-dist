# Midolec Examples

This folder contains small input texts that users can process after installing
or preparing a Midolec package.

Generated `.json` and `.md` outputs in this folder are ignored by Git, except
for documentation files named `README.md`.

## V6 Examples

Run from `midolec-v6/`:

```bash
./midolec-v6 ../examples/v6/es/legal_cross_references.txt
./midolec-v6 -L en ../examples/v6/en/plain_language_terms.txt
```

Midolec V6 creates the `.json` output next to the input file when no explicit
output path is provided.

## V7-a1 Examples

Run from `midolec-v7-a1/` after the alpha binary has been built and copied into
that folder:

```bash
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

When Markdown report generation is enabled, V7-a1 may create both `.json` and
`.md` outputs next to the input file.
