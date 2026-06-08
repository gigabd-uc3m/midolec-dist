# Midolec V7-a1 Runtime Provisioning

This folder contains lightweight runtime provisioning helpers for the V7-a1
partial alpha package.

V7-a1 is still an alpha distribution. The provisioning flow may not yet match
the stable V6 guided installer and dependency checker.

## Available Scripts

```text
install_configure_freeling.sh
  Prepares the Spanish FreeLing runtime assets when available.

install_spacy_en.sh
  Prepares the English spaCy dependencies and model when available.

freeling/
  Helper scripts used by install_configure_freeling.sh.
```

## Expected Usage

Run commands from the `midolec-v7-a1/` package root:

```bash
bash runtime/provisioning/install_configure_freeling.sh
bash runtime/provisioning/install_spacy_en.sh
```

After the V7-a1 binary has been rebuilt and copied into the package folder:

```bash
./midolec-v7-a1 -H
./midolec-v7-a1 ../examples/v7-a1/sample_es.txt
```

## Git Hygiene

Provisioning scripts are tracked. Installed runtime assets are not.

Do not commit:

- `runtime/freeling/lib/`;
- `runtime/freeling/share/freeling/common/`;
- `runtime/freeling/share/freeling/es/`;
- `runtime/spacy/models/`;
- generated JSON outputs;
- generated Markdown reports.
