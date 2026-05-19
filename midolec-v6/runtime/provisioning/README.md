# Midolec V6 Runtime Provisioning

This folder contains the scripts used to prepare external runtime assets for
Midolec V6. The scripts are versioned because they are part of the deployment
process, but the files they install are intentionally ignored by Git.

Unless stated otherwise, commands in this document are executed from the
repository root.

## Recommended First-Time Setup

For Spanish/FreeLing, collaborators should use the global installer:

```bash
# 1) Install GitHub CLI if it is not available yet.
gh --version

# 2) Authenticate with a GitHub account that has access to gigabd-uc3m/midolec-dist.
gh auth login

# 3) Optional: verify that authentication works.
gh auth status

# 4) Install, configure and check FreeLing.
v6/runtime/provisioning/install_configure_freeling.sh

# 5) Execute Midolec from the v6 folder.
cd v6
python3 midolec.py input_text.txt
```

The global installer runs the full FreeLing setup sequence:

```text
freeling/install_libs.sh
freeling/install_resources.sh
freeling/patch_freeling_rpath.sh
freeling/check_runtime.sh
```

This means the user normally runs one FreeLing script instead of four.

Important: the current V6 strategy is to patch `_pyfreeling.so` and the native
FreeLing libraries so they resolve `runtime/freeling/lib/` through
RPATH/RUNPATH. Users should not need to export `LD_LIBRARY_PATH` manually for
normal execution once the setup script has finished.

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
every time Midolec is executed. The authenticated GitHub account must have
access to the private repository `gigabd-uc3m/midolec-dist`.

The default release used by the scripts is:

```text
repo: gigabd-uc3m/midolec-dist
tag:  v6-runtime-2026-05-07
url:  https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07
```

## Scripts

```text
install_configure_freeling.sh
  Recommended FreeLing entry point. It installs compatible native libraries,
  installs common/ and es/ resources, patches RPATH/RUNPATH, and runs the final
  runtime check.

install_spacy_en.sh
  Installs the Python dependencies used by the English backend: spacy, pyphen,
  and en_core_web_sm. It also copies the downloaded model under
  v6/runtime/spacy/models/.

freeling/install_libs.sh
  Advanced script. Downloads or copies the native FreeLing shared libraries
  compatible with core/vendor/freeling/_pyfreeling.so.

freeling/install_resources.sh
  Advanced script. Downloads or copies the FreeLing resource folders needed by
  Spanish: common/ and es/.

freeling/patch_freeling_rpath.sh
  Advanced script. Patches `_pyfreeling.so` and the native FreeLing libraries
  so sibling dependencies are resolved from runtime/freeling/lib/.

freeling/check_runtime.sh
  Advanced script. Validates the local FreeLing runtime layout. It can check
  the full runtime or only one part with --libs-only or --resources-only.
```

## Expected Runtime Targets

```text
v6/runtime/freeling/lib/
v6/runtime/freeling/share/freeling/common/
v6/runtime/freeling/share/freeling/es/
v6/runtime/spacy/models/
```

## Default GitHub Release Usage

After publishing the Release assets, a collaborator with repository access can
prepare FreeLing with:

```bash
gh auth login
v6/runtime/provisioning/install_configure_freeling.sh
cd v6
python3 midolec.py input_text.txt
```

The release can also be pinned explicitly:

```bash
v6/runtime/provisioning/install_configure_freeling.sh \
  --release-url https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07
```

Or by passing repo and tag separately:

```bash
v6/runtime/provisioning/install_configure_freeling.sh \
  --github-repo gigabd-uc3m/midolec-dist \
  --release-tag v6-runtime-2026-05-07
```

## Advanced Usage

The advanced scripts inside `freeling/` are still available when maintainers
need to install only one part:

```bash
v6/runtime/provisioning/freeling/install_libs.sh --archive /path/to/libs.tar.gz
v6/runtime/provisioning/freeling/install_resources.sh --archive /path/to/resources.tar.gz
bash v6/runtime/provisioning/freeling/patch_freeling_rpath.sh v6
bash v6/runtime/provisioning/freeling/check_runtime.sh
```

Copy the example file and fill in project-specific artifact URLs if a future
runtime source is needed:

```bash
cp v6/runtime/provisioning/runtime_sources.env.example runtime_sources.env
```

Then either source it:

```bash
source runtime_sources.env
```

or pass repo/tag/release-url options directly to the scripts.
