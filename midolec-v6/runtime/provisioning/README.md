# Midolec V6 Runtime Provisioning

This folder contains the scripts used to prepare external runtime assets for
Midolec V6. The scripts are versioned because they are part of the deployment
process, but the files they install are intentionally ignored by Git.

Unless stated otherwise, commands in this document are executed from the
packaged application root: `midolec-v6/`.

## Supported Environments

The current Midolec V6 package is a Linux runtime. Run these scripts in Ubuntu,
a compatible Linux server, or WSL Ubuntu on Windows.

Do not run the V6 provisioning flow from a local MobaXterm/Cygwin/MSYS/Git Bash
terminal. Those shells can look Unix-like, but they are not the Ubuntu/WSL
runtime expected by the Linux binary and the FreeLing shared libraries. MobaXterm
is fine as an SSH client when the commands actually run on a Linux server.

## Recommended First-Time Setup

Most users should run the guided installer. It asks whether to prepare the
Spanish/FreeLing backend, the English/spaCy backend, or both. Before changing
anything, it prints a checklist of available and missing dependencies, explains
the planned actions, and asks for confirmation.

```bash
# 1) Move to the packaged application root.
cd midolec-v6

# 2) Install the runtime backend selected by the user.
bash runtime/provisioning/install_midolec_runtime.sh

# 3) Optional: run the read-only diagnostic checklist again.
bash runtime/provisioning/doctor.sh --backend all

# 4) Execute Midolec.
./midolec-v6 input_text.txt output.json
```

For non-interactive FreeLing-only setup, maintainers can still run:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling --yes
```

Internally, the FreeLing installer runs this setup sequence:

```text
freeling/install_libs.sh
freeling/install_resources.sh
freeling/patch_freeling_rpath.sh
freeling/check_runtime.sh
```

This means the user normally runs one guided script instead of remembering the
individual FreeLing steps.

Important: the current V6 strategy is to patch `_pyfreeling.so` and the native
FreeLing libraries so they resolve `runtime/freeling/lib/` through
RPATH/RUNPATH. Users should not need to export `LD_LIBRARY_PATH` manually for
normal execution once the setup script has finished.

## Recommended Artifact Source

Use the public GitHub Release published in the Midolec distribution/runtime
assets repository. The provisioning scripts download Release assets directly
with `curl` or `wget`, so collaborators do not need GitHub CLI or a personal
access token for the normal flow.

If the repository becomes private again, the same scripts can fall back to
GitHub CLI after `gh auth login`.

The default release used by the scripts is:

```text
repo: gigabd-uc3m/midolec-dist
tag:  v6-runtime-2026-05-07
url:  https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07
```

## Scripts

```text
install_midolec_runtime.sh
  Recommended user-facing installer. It asks which backend to prepare, runs a
  checklist, installs missing Ubuntu/WSL packages after confirmation, launches
  the backend installers, and prints a final success/failure summary.

doctor.sh
  Read-only diagnostic helper. It prints OK/MISSING/WARN checklist items for
  FreeLing, spaCy, or both, and tells users which installer to run next.

install_configure_freeling.sh
  Non-interactive FreeLing entry point. It installs compatible native libraries,
  installs common/ and es/ resources, patches RPATH/RUNPATH, and runs the final
  runtime check. The guided installer calls this script when FreeLing is
  selected.

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
runtime/freeling/lib/
runtime/freeling/share/freeling/common/
runtime/freeling/share/freeling/es/
runtime/spacy/models/
```

## Default GitHub Release Usage

After publishing the Release assets, a collaborator can prepare the runtime
with:

```bash
bash runtime/provisioning/install_midolec_runtime.sh
./midolec-v6 input_text.txt output.json
```

The release can also be pinned explicitly:

```bash
bash runtime/provisioning/install_configure_freeling.sh \
  --release-url https://github.com/gigabd-uc3m/midolec-dist/releases/tag/v6-runtime-2026-05-07
```

Or by passing repo and tag separately:

```bash
bash runtime/provisioning/install_configure_freeling.sh \
  --github-repo gigabd-uc3m/midolec-dist \
  --release-tag v6-runtime-2026-05-07
```

## Advanced Usage

The advanced scripts inside `freeling/` are still available when maintainers
need to install only one part:

```bash
runtime/provisioning/freeling/install_libs.sh --archive /path/to/libs.tar.gz
runtime/provisioning/freeling/install_resources.sh --archive /path/to/resources.tar.gz
bash runtime/provisioning/freeling/patch_freeling_rpath.sh .
bash runtime/provisioning/freeling/check_runtime.sh
```

Copy the example file and fill in project-specific artifact URLs if a future
runtime source is needed:

```bash
cp runtime/provisioning/runtime_sources.env.example runtime_sources.env
```

Then either source it:

```bash
source runtime_sources.env
```

or pass repo/tag/release-url options directly to the scripts.
