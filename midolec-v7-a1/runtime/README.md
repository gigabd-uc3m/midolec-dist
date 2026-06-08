# Midolec V7-a1 Runtime Folder

This folder contains runtime notes and lightweight provisioning scripts for the
Midolec V7-a1 partial alpha package.

V7-a1 is not yet the stable distribution package. Runtime behavior may change
while the alpha binary is being rebuilt and validated.

## Expected Structure

```text
runtime/
├── freeling/
│   ├── lib/
│   └── share/freeling/
├── provisioning/
│   ├── install_configure_freeling.sh
│   └── install_spacy_en.sh
└── spacy/
    └── models/
```

Runtime assets installed under `runtime/freeling/` and `runtime/spacy/models/`
are ignored by Git.

## Execution

After the V7-a1 binary exists, execute the package from `midolec-v7-a1/`:

```bash
./midolec-v7-a1 -H
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

Do not use source-repository entry points such as `python3 midolec.py` in this
distribution package unless you are explicitly debugging the source repository.

## Configuration

Runtime paths are configured in:

```text
midolecConfig.toml
```

Relative paths are resolved from the `midolec-v7-a1/` package root.

## Alpha Notes

The V7-a1 runtime scripts are included as lightweight helpers. Before sharing a
V7-a1 build with collaborators, validate the binary, runtime assets, JSON
output, and optional Markdown report generation.
