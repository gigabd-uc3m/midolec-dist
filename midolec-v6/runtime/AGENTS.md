# Runtime Agent Guide

This directory contains runtime documentation and provisioning scripts. Heavy runtime assets are normally installed or attached as release assets, not committed to the source repository.

## Rules

- Do not commit downloaded FreeLing resources, spaCy models or generated runtime folders.
- Do not modify native `.so` files directly.
- Do not add launcher scripts unless preflight/provisioning cannot solve the problem.
- Keep runtime instructions reproducible for WSL/Linux users.
- Windows Spanish/FreeLing usage currently goes through WSL rather than native Windows FreeLing.

## FreeLing Validation

Run the closest applicable command:

```bash
bash runtime/provisioning/check_freeling_runtime.sh
bash runtime/provisioning/check_freeling_runtime.sh --libs-only
bash runtime/provisioning/check_freeling_runtime.sh --resources-only
```

## Distribution Notes

- The distribution package should include `runtime/README.md` and `runtime/provisioning/`.
- FreeLing libs/resources and spaCy models should be versioned release assets when they are too heavy for source.
- `midolec-dist` is the distribution/runtime assets repository, not the canonical source-code repository.
