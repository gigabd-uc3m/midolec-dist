# Runtime Dependencies

Runtime dependencies are required to execute Midolec, but they are not part of
the source code. They are installed or checked by the provisioning scripts in
`midolec-v6/runtime/provisioning/`.

## Recommended Installation

For end users, use the guided installer:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh
```

The installer asks which backend should be prepared, shows an `OK` / `MISSING`
/ `WARN` checklist, asks for confirmation, installs the missing pieces, and
prints a final summary.

To diagnose the environment without changing anything:

```bash
cd midolec-v6
bash runtime/provisioning/doctor.sh --backend all
```

## Direct Installation

Direct installation skips the interactive question and selects a backend
explicitly. This is useful for maintainers, scripted setup, or users who
already know which backend they need.

Install FreeLing for Spanish:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling --yes
```

Install spaCy for English:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend spacy --yes
```

Install both FreeLing and spaCy:

```bash
cd midolec-v6
bash runtime/provisioning/install_midolec_runtime.sh --backend all --yes
```

## FreeLing

The Spanish backend requires:

- Native shared libraries in `runtime/freeling/lib/`.
- Common linguistic resources in `runtime/freeling/share/freeling/common/`.
- Spanish linguistic resources in `runtime/freeling/share/freeling/es/`.

The installer also configures RPATH/RUNPATH so `_pyfreeling.so` can resolve the
native libraries from `runtime/freeling/lib/`. Users should not need to export
`LD_LIBRARY_PATH` manually.

## spaCy

The English backend requires:

- `spacy`.
- `pyphen`.
- The `en_core_web_sm` model.

When possible, the installer copies the model into
`runtime/spacy/models/en_core_web_sm/` so the package can prefer the bundled
runtime model.

## Asset Downloads

The provisioning scripts download runtime assets from the public GitHub Release
using `curl` or `wget`. GitHub CLI is not required for the normal flow.

If the distribution repository becomes private again, the same scripts can use
GitHub CLI as a fallback after running `gh auth login` in the same Ubuntu/WSL
terminal.
