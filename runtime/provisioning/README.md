# Runtime provisioning

Scripts for installing external runtime dependencies used by packaged Midolec
builds.

## Private repository authentication

This distribution repository is currently private. Before downloading assets
from GitHub Releases, authenticate with GitHub CLI:

```bash
gh auth login
gh auth status
```

The authenticated account must have access to `gigabd-uc3m/midolec-dist`.

## FreeLing for Spanish

Install compatible native libraries:

```bash
bash runtime/provisioning/install_freeling_libs.sh
```

Install Spanish linguistic resources:

```bash
bash runtime/provisioning/install_freeling_resources.sh
```

Before running the Spanish backend:

```bash
export LD_LIBRARY_PATH="$PWD/runtime/freeling/lib:${LD_LIBRARY_PATH:-}"
```

## spaCy for English

Install Python dependencies and the English model:

```bash
bash runtime/provisioning/install_spacy_en.sh
```

## Custom runtime source

If a release asset is not available yet, scripts can also install from a local
archive:

```bash
bash runtime/provisioning/install_freeling_libs.sh --archive /path/to/libs.tar.gz
bash runtime/provisioning/install_freeling_resources.sh --archive /path/to/resources.tar.gz
```

The default release source can be overridden by copying
`runtime_sources.env.example` to `runtime_sources.env`, editing it, and running:

```bash
source runtime/provisioning/runtime_sources.env
```
