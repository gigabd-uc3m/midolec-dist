# V6 Release Checklist

Use this checklist before publishing or replacing the V6 package.

## Build And Package

1. Build the binary from the canonical `midolec` source repository.
2. Copy the rebuilt executable workspace into `midolec-v6/`.
3. Ensure `_internal/base_library.zip` is present.
4. Ensure editable configuration files are present:

```text
midolec-v6/midolecConfig.toml
midolec-v6/config/es.toml
midolec-v6/config/en.toml
```

## Runtime

1. Confirm provisioning scripts are executable.
2. Confirm FreeLing runtime paths are documented.
3. Confirm spaCy model installation is documented.
4. Confirm generated outputs are ignored by Git.

## Validation

Run from `midolec-v6/`:

```bash
./midolec-v6 -H
bash runtime/provisioning/doctor.sh --backend all
./midolec-v6 ../examples/v6/es/legal_cross_references.txt
./midolec-v6 -L en ../examples/v6/en/plain_language_terms.txt
```

Expected result:

- the help command starts normally;
- the dependency checker prints the expected checklist;
- Spanish and English example commands generate JSON outputs;
- no manual `LD_LIBRARY_PATH` export is required for normal Spanish execution.

## Documentation

Review:

- `README.md`;
- `midolec-v6/README.md`;
- `midolec-v6/docs/`;
- `examples/README.md`;
- `docs/VERSION_MATRIX.md`;
- `docs/RELEASES.md`.
