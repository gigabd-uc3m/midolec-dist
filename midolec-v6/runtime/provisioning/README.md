# Midolec v6 Runtime Provisioning

This folder contains scripts that prepare the external runtime assets used by
Midolec v6. They are versioned because they are part of the deployment process,
but the files they install are intentionally ignored by Git.

Unless stated otherwise, commands in this document are executed from the
`midolec-v6/` package root.

## Recommended first-time setup

```bash
# 1) Install GitHub CLI if it is not installed yet.
gh --version

# 2) Authenticate with a GitHub account that has access to gigabd-uc3m/midolec-dist.
gh auth login

# 3) Optional: verify that authentication works.
gh auth status

# 4) Download and install the FreeLing native libraries.
runtime/provisioning/install_freeling_libs.sh

# 5) Download and install the FreeLing Spanish resources.
runtime/provisioning/install_freeling_resources.sh

# 6) Patch the Python binding and the FreeLing runtime libraries for RPATH/RUNPATH.
bash runtime/provisioning/patch_freeling_rpath.sh .

# 7) Execute Midolec from the package root.
./midolec-v6 input_text.txt
```

Important: the current V6 strategy is to patch `_pyfreeling.so` and the native
FreeLing libraries so they resolve `runtime/freeling/lib/` through
RPATH/RUNPATH. Users should not need to export `LD_LIBRARY_PATH` manually for
normal execution once the patch script has been applied.

If `gh --version` fails, install GitHub CLI first. On Ubuntu/WSL, follow the
official GitHub CLI installation instructions or ask a project maintainer for
the team-approved installation command.

If `gh auth status` says the user is not logged in, repeat `gh auth login`.

If the download fails with `HTTP 404`, `not found`, or `permission denied`, the
most likely cause is that the GitHub account does not have access to the
private Midolec repository.

If Midolec fails with an error about missing FreeLing RPATH/RUNPATH
configuration, run:

```bash
bash runtime/provisioning/patch_freeling_rpath.sh .
```

## Recommended Artifact Source

Use the private GitHub Release published in the Midolec distribution/runtime
assets repository. Because the repository is private, collaborators must
authenticate with GitHub CLI before downloading runtime assets:

```bash
gh auth login
```

`gh` is the official GitHub command-line tool. It is needed here because the
runtime assets are attached to a private GitHub Release, so a normal anonymous
`curl` download cannot access them.

The collaborator only needs to run `gh auth login` once per machine/user, not
every time Midolec is executed. **The authenticated GitHub account must have
access to the private repository `gigabd-uc3m/midolec-dist`.**

The default release used by the scripts is:

```text
repo: gigabd-uc3m/midolec-dist
tag:  v6-runtime-2026-05-07
url:  https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07
```

If runtime assets are later moved to another repository or distribution
workspace, the same scripts can be reused by passing `--github-repo`,
`--release-tag`, `--release-url`, or the equivalent environment variables.

Google Drive can work only when the URL is a real direct-download link, but it
is less reproducible because large files may require browser confirmation or
account permissions.

## Scripts

```text
install_spacy_en.sh
  Installs the Python dependencies used by the English backend:
  spacy, pyphen, and en_core_web_sm. It also copies the downloaded model under
  runtime/spacy/models/ so the English loader can prefer the local runtime
  model when available.

  In source-code execution, these dependencies are imported from the active
  Python environment. In a PyInstaller binary, `spacy` and `pyphen` must also
  have been included when the executable was built; this script cannot add
  Python packages into an already-built `_internal/` bundle.

check_freeling_runtime.sh
  Validates the local FreeLing runtime layout. It can check the full runtime or
  only one part with --libs-only or --resources-only. The FreeLing installers
  call it automatically after installing their own artifact type.

patch_freeling_rpath.sh
  Patches `_pyfreeling.so` so it resolves native FreeLing libraries from
  `runtime/freeling/lib/` through RPATH/RUNPATH. It also patches the native
  FreeLing libraries themselves with `$ORIGIN` so sibling dependencies can be
  resolved from the same folder.

install_freeling_resources.sh
  Downloads or copies the FreeLing resource folders needed by Spanish:
  common/ and es/. By default it downloads the resources archive from the
  private GitHub Release and verifies SHA256SUMS.

install_freeling_libs.sh
  Downloads or copies the native FreeLing shared libraries compatible with
  core/vendor/freeling/_pyfreeling.so. By default it downloads the libraries
  archive from the private GitHub Release and verifies SHA256SUMS.
```

## Expected Runtime Targets

```text
runtime/freeling/lib/
runtime/freeling/share/freeling/common/
runtime/freeling/share/freeling/es/
runtime/spacy/models/
```

For Spanish/FreeLing execution, the runtime libraries should be discoverable
through RPATH/RUNPATH after running:

```bash
bash runtime/provisioning/patch_freeling_rpath.sh .
```

## Default GitHub Release Usage

After publishing the Release assets, a collaborator with repository access can
prepare FreeLing with:

```bash
gh auth login
runtime/provisioning/install_freeling_libs.sh
runtime/provisioning/install_freeling_resources.sh
bash runtime/provisioning/patch_freeling_rpath.sh .
bash runtime/provisioning/check_freeling_runtime.sh
./midolec-v6 input_text.txt
```


The scripts can also be pinned explicitly:

```bash
runtime/provisioning/install_freeling_libs.sh \
  --release-url https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07

runtime/provisioning/install_freeling_resources.sh \
  --release-url https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07
```

Or by passing repo and tag separately:

```bash
runtime/provisioning/install_freeling_libs.sh \
  --github-repo gigabd-uc3m/midolec-dist \
  --release-tag v6-runtime-2026-05-07

runtime/provisioning/install_freeling_resources.sh \
  --github-repo gigabd-uc3m/midolec-dist \
  --release-tag v6-runtime-2026-05-07
```

## Alternative Source Configuration

Copy the example file and fill in project-specific artifact URLs:

```bash
cp runtime/provisioning/runtime_sources.env.example runtime_sources.env
```

Then either source it:

```bash
source runtime_sources.env
```

or pass URLs directly to the scripts with `--url`.

Local archives and local folders are still supported:

```bash
runtime/provisioning/install_freeling_libs.sh --archive /path/to/libs.tar.gz
runtime/provisioning/install_freeling_resources.sh --archive /path/to/resources.tar.gz
```
