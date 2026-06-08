# Troubleshooting Midolec V6

This document collects common installation and execution errors for the Midolec
V6 distribution package.

Run commands from the package root:

```bash
cd midolec-v6
```

Before diagnosing a specific case, run the general checklist:

```bash
bash runtime/provisioning/doctor.sh --backend all
```

If you want the package to try to install missing dependencies automatically,
run:

```bash
bash runtime/provisioning/install_midolec_runtime.sh
```

## 1. Supported Environment

The current package is a Linux build. Use:

- Ubuntu or another compatible Linux distribution.
- WSL Ubuntu on Windows.
- MobaXterm only as an SSH client connected to a Linux server.

Do not run this package from local MobaXterm/Cygwin/MSYS/Git Bash shells on
Windows. Those shells may look Unix-like, but they are not the Ubuntu/WSL
runtime expected by the Linux binary and FreeLing shared libraries.

Quick check:

```bash
uname -s
```

Expected result:

```text
Linux
```

## 2. Public Asset Download Fails

Typical symptoms:

```text
curl: ...
wget: ...
Direct public download failed; trying GitHub CLI fallback...
```

Likely cause:

There is no connection to GitHub, the Release or asset does not exist, or
`curl` / `wget` is missing in Ubuntu/WSL.

Recommended fix:

```bash
sudo apt update
sudo apt install -y curl
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

If the distribution repository becomes private again, GitHub CLI may be needed
inside Ubuntu/WSL after running `gh auth login`.

## 3. Local MobaXterm Shell On Windows

Typical symptoms:

```text
gh: command not found
cygstart: command not found
```

Likely cause:

The package is running from a local MobaXterm shell, often from a `/mnt/c/...`
path. That environment uses a Cygwin-like layer and is not equivalent to
Ubuntu/WSL.

Fix:

Install WSL Ubuntu and run the installation from an Ubuntu terminal, or use
MobaXterm only to connect by SSH to a real Linux machine.

## 4. Release Access Or Private Repository Issue

Typical symptoms:

```text
HTTP 404
not found
permission denied
```

Likely cause:

The Release is no longer public, or the authenticated GitHub CLI account cannot
access `gigabd-uc3m/midolec-dist`.

Fix:

```bash
gh auth login
gh auth status
```

This should not affect the normal flow while `midolec-dist` remains public.

## 5. Missing Ubuntu/WSL System Libraries

Typical symptom in `freeling/check_runtime.sh`:

```text
libboost_program_options.so.1.74.0 => not found
```

Likely cause:

FreeLing assets are present, but the operating system is missing a Boost shared
library required by this build.

Recommended fix:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
bash runtime/provisioning/doctor.sh --backend freeling
```

## 6. Missing patchelf

Typical symptom:

```text
ERROR: patchelf is not installed.
```

Likely cause:

The system is missing the tool used to write RPATH/RUNPATH into `_pyfreeling.so`
and the native FreeLing libraries.

Recommended fix:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

## 7. Missing FreeLing RPATH/RUNPATH Configuration

Typical symptom:

```text
Missing FreeLing RPATH/RUNPATH configuration
```

Likely cause:

The FreeLing libraries exist in `runtime/freeling/lib/`, but `_pyfreeling.so`
does not yet know how to resolve them automatically from that folder.

Fix:

```bash
bash runtime/provisioning/freeling/patch_freeling_rpath.sh .
bash runtime/provisioning/freeling/check_runtime.sh
```

Do not solve this by manually exporting `LD_LIBRARY_PATH`. The current V6
strategy is to use RPATH/RUNPATH.

## 8. Missing Native FreeLing Library

Typical symptoms:

```text
libfreeling.so: cannot open shared object file
libfoma.so: cannot open shared object file
libtreeler.so: cannot open shared object file
libdynet.so: cannot open shared object file
libcrfsuite.so: cannot open shared object file
```

Likely cause:

The compatible native libraries were not downloaded, or they were removed from
`runtime/freeling/lib/`.

Recommended fix:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

Advanced fix:

```bash
bash runtime/provisioning/freeling/install_libs.sh
bash runtime/provisioning/freeling/patch_freeling_rpath.sh .
bash runtime/provisioning/freeling/check_runtime.sh --libs-only
```

## 9. Undefined Symbol In _pyfreeling.so

Typical symptom:

```text
undefined symbol: _ZN8freeling...
```

Likely cause:

`_pyfreeling.so` is loading an incompatible `libfreeling.so`. This can happen
when system libraries or libraries copied from another build are used.

Recommended fix:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
bash runtime/provisioning/doctor.sh --backend freeling
```

If the error persists, remove `runtime/freeling/lib/` and repeat the
installation from the official `midolec-dist` Release.

## 10. Missing FreeLing Linguistic Resources

Typical symptoms:

```text
Missing FreeLing resource folders
cannot open tokenizer.dat
cannot open splitter.dat
```

Likely cause:

The `common/` and `es/` resource folders are missing from
`runtime/freeling/share/freeling/`.

Recommended fix:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend freeling
```

Advanced fix:

```bash
bash runtime/provisioning/freeling/install_resources.sh
bash runtime/provisioning/freeling/check_runtime.sh --resources-only
```

## 11. English Backend Cannot Find spaCy Or pyphen

Typical symptoms:

```text
No module named spacy
No module named pyphen
Can't find model 'en_core_web_sm'
```

Likely cause:

The English backend dependencies or model were not installed.

Recommended fix:

```bash
bash runtime/provisioning/install_midolec_runtime.sh --backend spacy
bash runtime/provisioning/doctor.sh --backend spacy
```

## 12. PyInstaller Cannot Find encodings

Typical symptom:

```text
ModuleNotFoundError: No module named 'encodings'
Failed to start embedded python interpreter
```

Likely cause:

`midolec-v6/_internal/base_library.zip` is missing, or the `_internal/` folder
is incomplete. This usually happens when the distribution was copied only
partially.

Fix:

Download or copy the complete `midolec-dist` package again. Do not try to solve
this by installing Python packages on the system, because the binary uses the
embedded PyInstaller runtime stored in `_internal/`.

## 13. No JSON Output Is Created

Recommended checks:

```bash
./midolec-v6 -H
./midolec-v6 input_text.txt output.json
```

Review:

- The input file exists.
- The command is executed from `midolec-v6/`.
- `midolecConfig.toml` and `config/` are next to the executable.
- `bash runtime/provisioning/doctor.sh --backend all` prints `OK` for the
  backend you plan to use.

## Unknown Error

If the error does not match any section above, do not guess or keep reinstalling
random packages. Save the terminal output and follow the report template in
[06_REPORTING_UNKNOWN_ERRORS.md](06_REPORTING_UNKNOWN_ERRORS.md).

The report guide explains what information to include, including the operating
system, command executed, full error output, dependency checklist, and Midolec
version or commit.
