# Midolec v6 Runtime Folder

This folder centralizes external assets required by Midolec at execution time.
It is intentionally separated from the Python source code and from the public
TOML configuration.

## Structure

```text
runtime/
├── freeling/
│   ├── lib/
│   │   ├── libfreeling.so
│   │   ├── libfoma.so
│   │   ├── libtreeler.so
│   │   ├── libdynet.so
│   │   └── libcrfsuite.so
│   └── share/
│       └── freeling/
│           ├── common/
│           └── es/
├── provisioning/
│   ├── check_freeling_runtime.sh
│   ├── install_freeling_libs.sh
│   ├── install_freeling_resources.sh
│   ├── patch_freeling_rpath.sh
│   └── install_spacy_en.sh
└── spacy/
    └── models/
        └── en_core_web_sm/
```

## Why This Exists

FreeLing uses native C/C++ shared libraries. We found that relying on
`/usr/local/lib/libfreeling.so` is not reproducible enough, because a machine
can have a library with the right filename but a different ABI from
`_pyfreeling.so`.

For that reason, the Midolec v6 distribution should carry the exact FreeLing
runtime libraries that match the vendored Python binding:

```text
core/vendor/freeling/_pyfreeling.so
core/vendor/freeling/pyfreeling.py
```

Midolec now runs a Python preflight check before loading FreeLing or spaCy. If
the selected backend is incomplete, the program fails early with an actionable
message and the script that should be executed to install the missing assets.

## FreeLing native dependency resolution

Midolec V6 no longer expects users to export `LD_LIBRARY_PATH` manually. The
current strategy is:

1. Install the runtime libraries in `runtime/freeling/lib/`.
2. Install the linguistic resources in `runtime/freeling/share/freeling/`.
3. Patch `_pyfreeling.so` and the native FreeLing libraries with
   `patch_freeling_rpath.sh`.

After installing or copying the runtime folder, run:

```bash
bash runtime/provisioning/patch_freeling_rpath.sh .
```

This patches the binding so it resolves native libraries from
`runtime/freeling/lib/` through RPATH/RUNPATH.

After that, the canonical source entry point remains:

```bash
python3 midolec.py input.txt
```

## Configuration

`midolecConfig.toml` uses relative runtime paths:

```toml
[paths]
runtime_root = "runtime"
freeling_root = "runtime/freeling"
```

Relative paths are resolved from the v6 application root. Therefore FreeLing
resources are expected at:

```text
runtime/freeling/share/freeling/common/
runtime/freeling/share/freeling/es/
```

## spaCy

The English package depends on `spacy`, `pyphen`, and the English model
`en_core_web_sm`. For the intermediate v6 distribution, these should be handled
as runtime/model dependencies rather than being mixed with the Python source
code.

The preferred target location for a bundled spaCy model is:

```text
runtime/spacy/models/en_core_web_sm/
```

When that local folder exists, the English loader can prefer it instead of
depending only on a globally installed spaCy model.

The installer copies the loadable spaCy model directory, meaning the target
folder should contain `config.cfg` directly at:

```text
runtime/spacy/models/en_core_web_sm/config.cfg
```

If the model appears one level deeper, rerun the current provisioning script so
the runtime layout matches what the preflight and English loader expect.

## Provisioning Scripts

The `provisioning/` folder contains versioned scripts that populate this runtime
folder. These scripts are source-controlled, but the native libraries, FreeLing
resources, and spaCy models they install remain ignored by Git.

Recommended usage:

```bash
# Install the current English spaCy dependencies and model.
v6/runtime/provisioning/install_spacy_en.sh

# Install/check compatible FreeLing native libraries.
v6/runtime/provisioning/install_freeling_libs.sh --url "<release-asset-url>"

# Install FreeLing common/ and es/ resources.
v6/runtime/provisioning/install_freeling_resources.sh --url "<release-asset-url>"

# Patch the binding and the native libraries for RPATH/RUNPATH resolution.
bash v6/runtime/provisioning/patch_freeling_rpath.sh v6
```

For FreeLing archives, prefer GitHub Release assets or another stable direct
download URL. Google Drive is acceptable only when the link behaves as a direct
download without manual browser confirmation.
